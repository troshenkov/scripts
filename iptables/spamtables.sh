#!/bin/bash
IPTABLES=/sbin/iptables
FILE="/tmp/drop.lasso"
URL="http://www.spamhaus.org/drop/drop.lasso"
#echo ""
#echo -n "Applying DROP list to existing firewall..."
$IPTABLES -D INPUT -j Spamhaus
$IPTABLES -D OUTPUT -j Spamhaus
$IPTABLES -D FORWARD -j Spamhaus
$IPTABLES -F Spamhaus
$IPTABLES -X Spamhaus
[ -f $FILE ] && /bin/rm -f $FILE || :
cd /tmp
wget $URL
blocks=$(cat $FILE | egrep -v '^;' | awk '{ print $1}')
$IPTABLES -N Spamhaus
for ipblock in $blocks
do
#$IPTABLES -A Spamhaus -s $ipblock -j LOG --log-prefix "DROP List Block"
$IPTABLES -A Spamhaus -s $ipblock -j DROP
#echo $ipblock
done
$IPTABLES -I INPUT -j Spamhaus
$IPTABLES -I OUTPUT -j Spamhaus
$IPTABLES -I FORWARD -j Spamhaus
#echo "...Done"
/bin/rm -f $FILE

exit 0

