#!/bin/bash
# Script for blocking IPs which have been reported to www.badips.com
# Usage: Just execute by e.g. cron every day
# ---------------------------
 
_ipt=/sbin/iptables    # Location of iptables (might be correct)
_input=badips.db       # Name of database (will be downloaded with this name)
_pub_if=eth0           # Device which is connected to the internet (ex. $ifconfig for that)
_droplist=droplist     # Name of chain in iptables (Only change this if you have already a chain with this name)
#_level=5               # Blog level: not so bad/false report (0) over confirmed bad (3) to quite aggressive (5) (see www.badips.com for that)
_service=any           # Logged service (see www.badips.com for that)
_age=2m

# Get the bad IPs
#wget -qO- http://www.badips.com/get/list/${_service}/$_level > $_input || { echo "$0: Unable to download ip list."; exit 1; }
wget -qO- http://www.badips.com/get/list/${_service}/3?age=${_age} > $_input || { echo "$0: Unable to download ip list."; exit 1; }

### Setup our black list ###
# First flush it
$_ipt --flush $_droplist
# Create a new chain
$_ipt -N $_droplist
 
# Filter out comments and blank lines
# store each ip in $ip
for ip in `cat $_input`
do
    # Append everything to $_droplist
    $_ipt -A $_droplist -i ${_pub_if} -s $ip -j LOG --log-prefix "Drop Bad IP List"
    $_ipt -A $_droplist -i ${_pub_if} -s $ip -j DROP
done
 
# Finally, insert or append our black list
$_ipt -I INPUT -j $_droplist
$_ipt -I OUTPUT -j $_droplist
$_ipt -I FORWARD -j $_droplist
 
exit 0
