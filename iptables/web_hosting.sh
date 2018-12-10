#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)
# IPTables Rules for a web-hosting production server 

IPT="/sbin/iptables"
SERVER_IP=$(ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
PUB_IF="eth0"   # public interface
LO_IF="lo"      # loopback
SPOOFIP="127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 169.254.0.0/16 0.0.0.0/8 240.0.0.0/4 255.255.255.255/32 168.254.0.0/16 224.0.0.0/4 240.0.0.0/5 248.0.0.0/5 192.0.2.0/24"
AM_SERVERS="1.1.1.1 2.2.2.2 3.3.3.3/24"
# GOOGLE YANDEX YAHOO RAMBLER MAIL_RU BING_COM APORT GIGA LIVEINTERNET WEBALTA
GOOGLE="64.68.80.0/21 64.233.160.0/19 66.102.0.0/20 66.249.64.0/19 72.14.192.0/18 209.85.128.0/17 216.239.32.0/19"
YANDEX="77.88.0.0/18 87.250.224.0/19 93.158.128.0/18 95.108.128.0/17 213.180.192.0/19"
Yandex_Bot="37.9.115.0/24, 37.140.165.0/24, 77.88.22.0/25, 77.88.29.0/24, 77.88.31.0/24, 77.88.59.0/24, 84.201.146.0/24, 84.201.148.0/24, 84.201.149.0/24, 87.250.243.0/24, 87.250.253.0/24, 93.158.147.0/24, 93.158.148.0/24, 93.158.151.0/24, 93.158.153.0/32, 95.108.128.0/24, 95.108.138.0/24, 95.108.150.0/23, 95.108.158.0/24, 95.108.156.0/24, 95.108.188.128/25, 95.108.234.0/24, 95.108.248.0/24, 100.43.80.0/24, 130.193.62.0/24, 141.8.153.0/24, 178.154.165.0/24, 178.154.166.128/25, 178.154.173.29, 178.154.200.158, 178.154.202.0/24, 178.154.205.0/24, 178.154.239.0/24, 178.154.243.0/24, 37.9.84.253, 199.21.99.99, 178.154.162.29, 178.154.203.251, 178.154.211.250, 95.108.246.252"
YAHOO="67.195.0.0/16 69.147.64.0/18 72.30.0.0/16 74.6.0.0/16"
RAMBLER="81.19.64.0/19"                                                                                                                                                  
MAIL_RU="94.100.176.0/20 94.100.181.128/25 195.239.211.0/24"                                                                                                            
BING_COM="65.52.0.0/14 207.46.0.0/16"
APORT="194.67.18.0/24"                                                                                                                                                  
GIGA="66.231.188.0/24"                                                                                                                                                
LIVEINTERNET="88.212.202.0/26"                                                                                                                                           
WEBALTA="77.91.224.0/21"                                                                                                                                                
#                                                                                                                                                                        
EXT_SSH="4.4.4.4/28 5.5.5.5/29"
#                                                                                                                                                                        
CLOUDFLARE_IP_RANGE=$(curl http://www.cloudflare.com/ips-v4)
#                                                                                                                                                                        
LOCATION_IP_RANGE='0.0.0.0'
#
SYSCTL="/sbin/sysctl -w"
# Stop certain attacks
echo "Starting sysctl IPv4 settings..."                                                                                                                                             
# Avoid a smurf attack
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts=1
# Turn on protection for bad icmp error messages
$SYSCTL net.ipv4.icmp_ignore_bogus_error_responses=1
# Turn on syncookies for SYN flood attack protection
$SYSCTL net.ipv4.tcp_syncookies=1
# Turn on and log spoofed, source routed, and redirect packets
$SYSCTL net.ipv4.conf.all.log_martians=1
$SYSCTL net.ipv4.conf.default.log_martians=1
# No source routed packets here
$SYSCTL net.ipv4.conf.all.accept_source_route=0
$SYSCTL net.ipv4.conf.default.accept_source_route=0
# Turn on reverse path filtering
# cat /proc/sys/net/ipv4/conf/all/rp_filter (USA 0, DE 1)
$SYSCTL net.ipv4.conf.all.rp_filter=1
$SYSCTL net.ipv4.conf.default.rp_filter=1
# Make sure no one can alter the routing tables
$SYSCTL net.ipv4.conf.all.accept_redirects=0
$SYSCTL net.ipv4.conf.default.accept_redirects=0
$SYSCTL net.ipv4.conf.all.secure_redirects=0
$SYSCTL net.ipv4.conf.default.secure_redirects=0
# Don't act as a router
$SYSCTL net.ipv4.ip_forward=0
$SYSCTL net.ipv4.conf.all.send_redirects=0
$SYSCTL net.ipv4.conf.default.send_redirects=0
# Turn on execshild
$SYSCTL kernel.exec-shield=1
$SYSCTL kernel.randomize_va_space=1
# Tuen IPv6
## Hetzner Online AG installimage
# sysctl config
#net.ipv4.ip_forward=1
$SYSCTL net.ipv4.conf.all.rp_filter=1
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts=1
# ipv6 settings (no autoconfiguration)
$SYSCTL net.ipv6.conf.default.autoconf=0
$SYSCTL net.ipv6.conf.default.accept_dad=0
$SYSCTL net.ipv6.conf.default.accept_ra=0
$SYSCTL net.ipv6.conf.default.accept_ra_defrtr=0
$SYSCTL net.ipv6.conf.default.accept_ra_rtr_pref=0
$SYSCTL net.ipv6.conf.default.accept_ra_pinfo=0
$SYSCTL net.ipv6.conf.default.accept_source_route=0
$SYSCTL net.ipv6.conf.default.accept_redirects=0
$SYSCTL net.ipv6.conf.default.forwarding=0
$SYSCTL net.ipv6.conf.all.autoconf=0
$SYSCTL net.ipv6.conf.all.accept_dad=0
$SYSCTL net.ipv6.conf.all.accept_ra=0
$SYSCTL net.ipv6.conf.all.accept_ra_defrtr=0
$SYSCTL net.ipv6.conf.all.accept_ra_rtr_pref=0
$SYSCTL net.ipv6.conf.all.accept_ra_pinfo=0
$SYSCTL net.ipv6.conf.all.accept_source_route=0
$SYSCTL net.ipv6.conf.all.accept_redirects=0
$SYSCTL net.ipv6.conf.all.forwarding=0
$SYSCTL fs.enforce_symlinksifowner=1
$SYSCTL fs.symlinkown_gid=99
# CageFS
$SYSCTL fs.proc_can_see_other_uid=0
#
# Optimization for port usefor LBs
# Increase system file descriptor limit
#$SYSCTL fs.file-max=65535
# Allow for more PIDs (to reduce rollover problems); may break some programs 32768
#$SYSCTL kernel.pid_max=65536
# Increase system IP port limits
$SYSCTL net.ipv4.ip_local_port_range='2000 65000'
# Increase TCP max buffer size setable using setsockopt()
$SYSCTL net.ipv4.tcp_rmem='4096 87380 8388608'
$SYSCTL net.ipv4.tcp_wmem='4096 87380 8388608'
# Increase Linux auto tuning TCP buffer limits
# min, default, and max number of bytes to use
# set max to at least 4MB, or higher if you use very high BDP paths
# Tcp Windows etc
$SYSCTL net.core.rmem_max=8388608
$SYSCTL net.core.wmem_max=8388608
$SYSCTL net.core.netdev_max_backlog=5000
$SYSCTL net.ipv4.tcp_window_scaling=1
#
$SYSCTL net.ipv4.tcp_max_syn_backlog=4096
$SYSCTL net.ipv4.tcp_keepalive_time=60
$SYSCTL net.ipv4.tcp_keepalive_intvl=10
$SYSCTL net.ipv4.tcp_keepalive_probes=5
$SYSCTL net.ipv4.tcp_synack_retries=1
$SYSCTL net.ipv4.tcp_fin_timeout=10
#
#####
echo "Starting IPv4 Firewall..."
$IPT -F
$IPT -P INPUT DROP
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
# Allow loopback input/output
$IPT -A INPUT -i ${LO_IF} -j ACCEPT
$IPT -A OUTPUT -o ${LO_IF} -j ACCEPT
# Allow the three way handshake
#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Drop SYN packets
$IPT -A INPUT -i ${PUB_IF} -p tcp ! --syn -m state --state NEW -j DROP
$IPT -I INPUT -i ${PUB_IF} -m conntrack --ctstate NEW -p tcp ! --syn -j DROP
# Drop Fragments packets
$IPT -A INPUT -i ${PUB_IF} -f -j DROP
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL ALL -j DROP
# Drop NULL packets
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix " NULL Packets "
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL NONE -j DROP
$IPT  -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
# Drop XMAS packets
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags ALL ALL -j DROP
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -m limit --limit 5/m --limit-burst 7 -j LOG --log-prefix " XMAS Packets "
$IPT -A INPUT -i ${PUB_IF} -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
# Log and block spoofed ips
$IPT -N spooflist
for ip in $SPOOFIP; do
$IPT -A spooflist -i ${PUB_IF} -s "$ip" -j LOG --log-prefix " SPOOF List Block "
$IPT -A spooflist -i ${PUB_IF} -s "$ip" -j DROP
done
$IPT -I INPUT -j spooflist
$IPT -I OUTPUT -j spooflist
$IPT -I FORWARD -j spooflist
## Spoofing protect
$IPT -I INPUT -m conntrack --ctstate NEW,INVALID -p tcp --tcp-flags SYN,ACK SYN,ACK -j REJECT --reject-with tcp-reset
## Simple dDoS protect
$IPT -A INPUT -p tcp -m tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
# Stop smurf attacks
$IPT -I INPUT -p icmp -f -j DROP
$IPT -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
$IPT -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
$IPT -A INPUT -p icmp -m icmp -m limit --limit 1/second -j ACCEPT
# Log and get rid of broadcast / multicast and invalid 
$IPT  -A INPUT -i ${PUB_IF} -m pkttype --pkt-type broadcast -j LOG --log-prefix " Broadcast "
$IPT  -A INPUT -i ${PUB_IF} -m pkttype --pkt-type broadcast -j DROP
#
$IPT  -A INPUT -i ${PUB_IF} -m pkttype --pkt-type multicast -j LOG --log-prefix " Multicast "
$IPT  -A INPUT -i ${PUB_IF} -m pkttype --pkt-type multicast -j DROP
# Drop all invalid packets
#$IPT  -A INPUT -i ${PUB_IF} -m state --state INVALID -j LOG --log-prefix " Invalid "
$IPT -A INPUT -m state --state INVALID -j DROP
$IPT -A FORWARD -m state --state INVALID -j DROP
$IPT -A OUTPUT -m state --state INVALID -j DROP
# Drop excessive RST packets to avoid smurf attacks
$IPT -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT
#
# Attempt to block portscans
# Attacking IP will be locked for 24 hours (3600 x 24 = 86400 Seconds)
$IPT -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
$IPT -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
# Remove attacking IP after 24 hours
$IPT -A INPUT -m recent --name portscan --remove
$IPT -A FORWARD -m recent --name portscan --remove
#
#### Allow ICMP
# incoming
$IPT -A INPUT -p icmp --icmp-type 8 -s 0/0 -d "${SERVER_IP}" -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type 0 -s "${SERVER_IP}" -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT
# outgoing
$IPT -A OUTPUT -p icmp --icmp-type 8 -s "${SERVER_IP}" -d 0/0 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 0 -s 0/0 -d "${SERVER_IP}" -m state --state ESTABLISHED,RELATED -j ACCEPT
#
#### Allow INTERNAL SSH
for ip in ${AM_SERVERS} ${EXT_SSH}; do
# incoming
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 513:65535 -d "${SERVER_IP}" --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 22 -d "$ip" --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
done
# outgoing
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 513:65535 -d 0/0 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 22 -d "${SERVER_IP}" --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
#
#### Allow SMTP
# incoming
#$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 1024:65535 -d "${SERVER_IP}" --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
#$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 25 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# outgoing
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 25 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
#### Allow MySQL
for ip in ${AM_SERVERS}; do
# incoming
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 1024:65535 -d "${SERVER_IP}" --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 3306 -d "$ip" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# outgoing
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d "$ip" --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 3306 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
done
#
#### Allow TELNET
for ip in ${AM_SERVERS}; do
# incoming
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 1024:65535 -d "${SERVER_IP}" --dport 23 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 23 -d "$ip" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# outgoing
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d "$ip" --dport 23 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 23 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
done
#
#### Allow DNS
# incoming Query
# TCP
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 1024:65535 -d "${SERVER_IP}" --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 53 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# UDP
$IPT -A INPUT -i ${PUB_IF} -p udp -s 0/0 --sport 1024:65535 -d "${SERVER_IP}" --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p udp -s "${SERVER_IP}" --sport 53 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# outgoing Query
# TCP
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 53 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# UDP
$IPT -A OUTPUT -o ${PUB_IF} -p udp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p udp -s 0/0 --sport 53 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
#### Allow outgoing NTP Client
$IPT -A OUTPUT -o ${PUB_IF} -p udp -s "${SERVER_IP}" --sport 123 -d 0/0 --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT  -i ${PUB_IF} -p udp -s 0/0 --sport 123 -d "${SERVER_IP}" -m state --state ESTABLISHED -j ACCEPT
#
#### Allow FTP
# Passive Mode (PassivePorts 49152 65534); echo `IPTABLES_MODULES="ip_conntrack_ftp"` >> /etc/sysconfig/iptables-config
modprobe ip_conntrack
modprobe ip_conntrack_ftp
for ip in ${AM_SERVERS} ${LOCATION_IP_RANGE}; do
# incoming 21
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 1024:65535 -d "${SERVER_IP}" --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 21 -d "$ip" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
done
# data
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 1024:65535 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# outgoing 20
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 20 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 1024:65535 -d "${SERVER_IP}" --dport 20 -m state --state ESTABLISHED -j ACCEPT
# outgoing 21
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 21 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
# HTTP RULES
# Allow WEB search robots, CloudFlare
for ip in $GOOGLE $YANDEX $YAHOO $RAMBLER $MAIL_RU $BING_COM $APORT $GIGA $LIVEINTERNET $WEBALTA $CLOUDFLARE_IP_RANGE $Yandex_Bot; do
$IPT -A INPUT -s "$ip" -p tcp -m tcp -d "${SERVER_IP}" --dport 80 -m state --state NEW -j ACCEPT
$IPT -A INPUT -s "$ip" -p tcp -m tcp -d "${SERVER_IP}" --dport 80 -j ACCEPT
done
# Limit the number of connections on the HTTP port from one ip sends no more 20 packages per 1 second
#$IPT -A INPUT -p tcp -m tcp -d "${SERVER_IP}" --dport 80 -m state --state NEW -m recent --name dpt80 --set
#$IPT -A INPUT -p tcp -m tcp -d "${SERVER_IP}" --dport 80 -m state --state NEW -m recent --name dpt80 --update --seconds 1 --hitcount 20 -j DROP
# Allow no more than 35 tcp connections to 80 port from one ip
#$IPT -A INPUT -p tcp -m tcp --syn -d "${SERVER_IP}" --dport 80 -m connlimit --connlimit-above 35 -j REJECT --reject-with tcp-reset
# incoming 80 (HTTP)
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 1024:65535 -d "${SERVER_IP}" --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 80 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
# outgoing 80 (HTTP)
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 80 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
# outgoing 443 (HTTPS)
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d 0/0 --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s 0/0 --sport 443 -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
# Cpanel WHM, 2082:2083 (cPanel http and https), 2086:2087 (WHM http and https), 2095:2096 (webmail http and https)
WHM_PORTS="2082:2096"
for ip in $AM_SERVERS; do
# incoming
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport 1024:65535 -d "${SERVER_IP}" --dport $WHM_PORTS -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport $WHM_PORTS -d "$ip" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# outgoing
$IPT -A OUTPUT -o ${PUB_IF} -p tcp -s "${SERVER_IP}" --sport 1024:65535 -d "$ip" --dport $WHM_PORTS -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p tcp -s "$ip" --sport $WHM_PORTS -d "${SERVER_IP}" --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
done
#
########################
# Brute Force Protection
$IPT -A INPUT -p tcp -m multiport --dports 25,110 -m state --state NEW -m recent --set --name ATTACK
$IPT -A INPUT -p tcp -m multiport --dports 25,110 -m state --state NEW -m recent --update --seconds 600 --hitcount 3  --rttl --name ATTACK -j DROP
#
# Allow udp/rtp
for ip in $AM_SERVERS; do
# incoming
$IPT -A INPUT -i ${PUB_IF} -p udp -s "$ip" -d "${SERVER_IP}" -m state --state NEW -j ACCEPT
$IPT -A OUTPUT -o ${PUB_IF} -p udp -s "${SERVER_IP}" -d "$ip" -m state --state ESTABLISHED -j ACCEPT
# outgoing
$IPT -A OUTPUT -o ${PUB_IF} -p udp -s "${SERVER_IP}" -d "$ip" -m state --state NEW -j ACCEPT
$IPT -A INPUT -i ${PUB_IF} -p udp -s "$ip" -d "${SERVER_IP}" -m state --state ESTABLISHED -j ACCEPT
done
#
# Reject All INPUT traffic
$IPT -A INPUT -j REJECT
#
#iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Reject all Output traffic
$IPT -A OUTPUT -j REJECT
# Reject Forwarding  traffic
$IPT -A FORWARD -j REJECT
#
#
/sbin/iptables-save > /etc/sysconfig/iptables
chmod go-r /etc/sysconfig/iptables
service iptables restart
echo "Done"
exit 0
