#!/bin/sh

# My IP
IP=0.0.0.0
# Flushing all rules
iptables -F
iptables -X
# Setting default filter policy
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
# Allow unlimited traffic on loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Allow incoming/outgoing IP only
iptables -A INPUT -p tcp -s ${IP} -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d ${IP} -m state --state ESTABLISHED -j ACCEPT
#
#SSH anti brute force
#/sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
#/sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 600 --hitcount 3  --rttl --name SSH -j DROP
#/sbin/iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# Allow incoming SSH on port 22
#/sbin/iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
# Allow ping
#/sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
#Allow ftp in passive mode
#modprobe ip_conntrack_ftp
#/sbin/iptables -A INPUT -p tcp -m tcp --dport 30000:50000 -j ACCEPT
#/sbin/iptables -A INPUT -p tcp -m tcp --dport 20 -j ACCEPT 
#/sbin/iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
# Allow MySQL only from a certain network
#/sbin/iptables -A INPUT -p tcp -m tcp -s XXX.XXX.XXX.0/24 --dport 3306 -j ACCEPT
#/sbin/iptables -A INPUT -p tcp -m tcp  --dport 3306 -j ACCEPT
#
# make sure nothing comes or goes out of this box
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP


/sbin/iptables-save > /etc/sysconfig/iptables
chmod go-r /etc/sysconfig/iptables
service iptables restart

echo "Done"

