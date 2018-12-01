#!/bin/bash

IPT=/sbin/iptables

$IPT -D INPUT -j nonTOR
$IPT -D OUTPUT -j nonTOR
$IPT -D FORWARD -j nonTOR
$IPT -F npnTOR
$IPT -X nonTOR
$IPT -N nonTOR

FILE=Tor_ip_list_ALL.csv

wget http://torstatus.blutmagie.de/ip_list_all.php/$FILE

for ip in `cat $FILE`; do
        $IPT -A nonTOR -s $ip -j DROP;
done

rm $FILE

$IPT -I INPUT -j nonTOR
$IPT -I OUTPUT -j nonTOR
$IPT -I FORWARD -j nonTOR

exit 0

