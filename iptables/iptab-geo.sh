#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)

SERVER_IP=`ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
PUB_IF=eth0

cd /usr/share/xt_geoip/
./xt_geoip_dl
./xt_geoip_build *.csv > INFO

IPT=/sbin/iptables
#echo ""
#echo -n "Applying DROP list to existing firewall..."
$IPT -D INPUT -j GEO
$IPT -D OUTPUT -j GEO
$IPT -D FORWARD -j GEO
$IPT -F GEO
$IPT -X GEO
$IPT -N GEO

#
# AF – Africa
# AS – Asia
# EU – Europe
# NA – North America
# OC – Oceania
# SA – South America
# A1 – an anonymous proxy
# A2 – a satellite provider
#
#_C="CN,ID,IN,PH,PK,SG,TH,AF,SA"
_CO1="FI,EE,LT,LV,NO,SE,PL,CZ,DE,FR,LU,NL,DK"
_CO2="RU,MD,US,UA"

#$IPT -A GEO  -j LOG --log-prefix "DROP GEO Block"
#$IPT -A GEO -m geoip --src-cc $_C -j DROP

# Anonymous proxy block
$IPT -A GEO -m geoip --src-cc A1 -j REJECT
# Protect HTTP for non RU traffic
# SO SLOW!! $IPT -I GEO -d ${SERVER_IP} -p tcp --dport 80 ! -i lo -m geoip ! --src-cc $_CO -m string --string 'POST /' --algo bm -j DROP
#$IPT -I GEO -d ${SERVER_IP} -p tcp --dport 80 ! -i lo -m geoip ! --src-cc $_CO1 -m string --string '/administrator' --algo bm -j DROP
#$IPT -I GEO -d ${SERVER_IP} -p tcp --dport 80 ! -i lo -m geoip ! --src-cc $_CO1 -m string --string '/bitrix' --algo bm -j DROP
#$IPT -I GEO -d ${SERVER_IP} -p tcp --dport 80 ! -i lo -m geoip ! --src-cc $_CO2 -m string --string '/administrator' --algo bm -j DROP
#$IPT -I GEO -d ${SERVER_IP} -p tcp --dport 80 ! -i lo -m geoip ! --src-cc $_CO2 -m string --string '/bitrix' --algo bm -j DROP
#
#	Allow HTTP for the China
$IPT -I GEO -d ${SERVER_IP} -p tcp ! --dport 80 ! -i lo -m geoip --src-cc CN,HK -j DROP
#
iptables -A GEO -m geoip --source-country PK,IN,BR,EG,PL,TH,VN,ID,AR,MX,KR,TR,RO -j REJECT
iptables -A GEO -m geoip --source-country PH,DZ,IR,MA,MY,PE,RS,SA,JP,SG,IL,CL,NG,TW -j REJECT
iptables -A GEO -m geoip --source-country CO,AR,JO,SN,NP,IN,UG,LA,SA,LY,MG,JM,SD,DO,TO -j REJECT
iptables -A GEO -m geoip --source-country CR,KW,FJ,SN,NI,HN,EC,PS,CL,ZA,VN,BO -j REJECT
#
# ALLOW UKRAINE TO FTP
$IPT -A GEO -i ${PUB_IF} -p tcp --sport 1024:65535 -d ${SERVER_IP} --dport 21 -m geoip --src-cc UA -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A GEO -o ${PUB_IF} -p tcp -s ${SERVER_IP} --sport 21 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
#
# Allow Cpanel
$IPT -A GEO -i ${PUB_IF} -p tcp --sport 1024:65535 -d ${SERVER_IP} --dport 2083 -m geoip --src-cc RU -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A GEO -o ${PUB_IF} -p tcp -s ${SERVER_IP} --sport 2083 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
# Allow SSH
$IPT -A GEO -i ${PUB_IF} -p tcp --sport 1024:65535 -d ${SERVER_IP} --dport 22 -m geoip --src-cc RU -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A GEO -o ${PUB_IF} -p tcp -s ${SERVER_IP} --sport 22 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT

$IPT -I INPUT -j GEO
$IPT -I OUTPUT -j GEO
$IPT -I FORWARD -j GEO
#echo "...Done"

exit 0


