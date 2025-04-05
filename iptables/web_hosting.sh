#!/bin/bash

# ===================================================================
# Apply Spamhaus DROP List to Firewall (iptables)
# ===================================================================
#
# This script fetches the Spamhaus DROP list and applies the IP blocks 
# to iptables to prevent access from known malicious IPs.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# IPTables Rules for a Web-hosting Production Server
# =================================================================== 

IPT="/sbin/iptables"
SYSCTL="/sbin/sysctl -w"
SERVER_IP=$(hostname -I | awk '{print $1}')  # Get public IP address of the server
PUB_IF="eth0"   # Public interface
LO_IF="lo"      # Loopback interface

# List of spoofed IPs to block
SPOOFIP="127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 169.254.0.0/16 0.0.0.0/8 240.0.0.0/4 255.255.255.255/32 168.254.0.0/16 224.0.0.0/4 240.0.0.0/5 248.0.0.0/5 192.0.2.0/24"
AM_SERVERS="1.1.1.1 2.2.2.2 3.3.3.3/24"
EXT_SSH="4.4.4.4/28 5.5.5.5/29"
CLOUDFLARE_IP_RANGE=$(curl -s http://www.cloudflare.com/ips-v4)

# Network Optimization Parameters
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts=1
$SYSCTL net.ipv4.icmp_ignore_bogus_error_responses=1
$SYSCTL net.ipv4.tcp_syncookies=1
$SYSCTL net.ipv4.conf.all.log_martians=1
$SYSCTL net.ipv4.conf.default.log_martians=1
$SYSCTL net.ipv4.conf.all.accept_source_route=0
$SYSCTL net.ipv4.conf.default.accept_source_route=0
$SYSCTL net.ipv4.conf.all.rp_filter=1
$SYSCTL net.ipv4.conf.default.rp_filter=1
$SYSCTL net.ipv4.conf.all.accept_redirects=0
$SYSCTL net.ipv4.conf.default.accept_redirects=0
$SYSCTL net.ipv4.conf.all.secure_redirects=0
$SYSCTL net.ipv4.conf.default.secure_redirects=0
$SYSCTL net.ipv4.ip_forward=0
$SYSCTL net.ipv4.conf.all.send_redirects=0
$SYSCTL net.ipv4.conf.default.send_redirects=0
$SYSCTL kernel.exec-shield=1
$SYSCTL kernel.randomize_va_space=1

# IPv4 settings
$SYSCTL net.ipv4.tcp_max_syn_backlog=4096
$SYSCTL net.ipv4.tcp_keepalive_time=60
$SYSCTL net.ipv4.tcp_keepalive_intvl=10
$SYSCTL net.ipv4.tcp_keepalive_probes=5
$SYSCTL net.ipv4.tcp_synack_retries=1
$SYSCTL net.ipv4.tcp_fin_timeout=10
$SYSCTL net.ipv4.tcp_rmem='4096 87380 8388608'
$SYSCTL net.ipv4.tcp_wmem='4096 87380 8388608'

# Initialize firewall
echo "Starting IPv4 Firewall..."
$IPT -F
$IPT -P INPUT DROP
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT

# Allow loopback traffic
$IPT -A INPUT -i ${LO_IF} -j ACCEPT
$IPT -A OUTPUT -o ${LO_IF} -j ACCEPT

# Drop SYN packets that don't initiate a connection (new TCP connections)
$IPT -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -j DROP
$IPT -I INPUT -i ${PUB_IF} -m conntrack --ctstate NEW -p tcp ! --syn -j DROP

# Block fragments and suspicious packets
$IPT -A INPUT -i ${PUB_IF} -f -j DROP
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL ALL -j DROP
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix " NULL Packets "
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -j DROP

# Block spoofed IPs
$IPT -N spooflist
for ip in $SPOOFIP; do
  $IPT -A spooflist -i ${PUB_IF} -s "$ip" -j LOG --log-prefix " SPOOF List Block "
  $IPT -A spooflist -i ${PUB_IF} -s "$ip" -j DROP
done
$IPT -I INPUT -j spooflist
$IPT -I OUTPUT -j spooflist
$IPT -I FORWARD -j spooflist

# Anti-DDoS measures: Simple rate limiting
$IPT -A INPUT -p tcp -m tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT

# Block excessive RST packets
$IPT -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Prevent port scanning by tracking IPs
$IPT -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
$IPT -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
$IPT -A INPUT -m recent --name portscan --remove
$IPT -A FORWARD -m recent --name portscan --remove

# Allow ICMP for pinging
$IPT -A INPUT -p icmp --icmp-type 8 -s 0/0 -d "${SERVER_IP}" -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type 0 -s "${SERVER_IP}" -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow INTERNAL SSH
for ip in ${AM_SERVERS} ${EXT_SSH}; do
  $IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 513:65535 -d "${SERVER_IP}" --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
  $IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 22 -d "$ip" --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
done

# Allow outgoing SMTP traffic
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 25 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT

# Allow MySQL access from authorized servers
for ip in ${AM_SERVERS}; do
  $IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --dport 3306 -j ACCEPT
  $IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 3306 -d "$ip" -j ACCEPT
done

echo "Firewall configuration complete."
