#!/bin/sh

# ===================================================================
# Basic Firewall Configuration Script
# ===================================================================
#
# This script configures firewall rules using iptables for enhanced security.
# It sets default policies, allows traffic on loopback, and configures specific rules for SSH and FTP.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Define My IP address
IP="0.0.0.0"

# Flushing all current rules
iptables -F
iptables -X

# Set default filter policy to DROP for security
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow unlimited traffic on loopback interface (lo)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow incoming and outgoing traffic for a specific IP only (replace 0.0.0.0 with actual IP)
iptables -A INPUT -p tcp -s ${IP} -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d ${IP} -m state --state ESTABLISHED -j ACCEPT

# SSH Anti-brute force protection (commented out for optional use)
# /sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
# /sbin/iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 600 --hitcount 3 --rttl --name SSH -j DROP
# /sbin/iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow incoming SSH traffic on port 22 (uncomment to enable)
# /sbin/iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

# Allow incoming ping requests (ICMP Echo)
# /sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# FTP in passive mode (uncomment to enable FTP support)
# modprobe ip_conntrack_ftp
# /sbin/iptables -A INPUT -p tcp -m tcp --dport 30000:50000 -j ACCEPT
# /sbin/iptables -A INPUT -p tcp -m tcp --dport 20 -j ACCEPT
# /sbin/iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT

# Allow MySQL traffic only from specific network (uncomment to enable)
# /sbin/iptables -A INPUT -p tcp -m tcp -s XXX.XXX.XXX.0/24 --dport 3306 -j ACCEPT
# /sbin/iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT

# Ensure that no other traffic comes or goes out of the system
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

# Save iptables rules
/sbin/iptables-save > /etc/sysconfig/iptables

# Set permissions for the iptables rules file
chmod go-r /etc/sysconfig/iptables

# Restart iptables service to apply the rules
service iptables restart

echo "Firewall configuration applied successfully."
