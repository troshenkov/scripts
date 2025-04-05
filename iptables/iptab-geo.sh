#!/bin/bash
# ===================================================================
# GeoIP-based Firewall Rules for Blocking/Allowing Traffic
# ===================================================================
#
# This script updates iptables rules based on GeoIP information,
# blocking or allowing traffic based on country of origin.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Configuration
PUB_IF=eth0                        # Public interface for traffic filtering
SERVER_IP=$(ifconfig eth0 | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1 }')
XT_GEOIP_DIR="/usr/share/xt_geoip"  # Path to the xt_geoip tool directory
IPT="/sbin/iptables"               # Path to iptables binary

# GeoIP Block Categories
BLOCKED_COUNTRIES="PK,IN,BR,EG,PL,TH,VN,ID,AR,MX,KR,TR,RO"
ADDITIONAL_BLOCKED_COUNTRIES="PH,DZ,IR,MA,MY,PE,RS,SA,JP,SG,IL,CL,NG,TW"
EXTRA_BLOCKED_COUNTRIES="CO,AR,JO,SN,NP,IN,UG,LA,SA,LY,MG,JM,SD,DO,TO"
MORE_BLOCKED_COUNTRIES="CR,KW,FJ,SN,NI,HN,EC,PS,CL,ZA,VN,BO"
ALLOWED_COUNTRIES="UA,RU,CN,HK"

# Function to download and build GeoIP data
update_geoip_data() {
    echo "Updating GeoIP data..."
    cd $XT_GEOIP_DIR
    ./xt_geoip_dl
    ./xt_geoip_build *.csv > INFO
}

# Function to initialize iptables chain if it doesn't exist
initialize_iptables_chain() {
    echo "Initializing iptables chain '$IPCHAIN'..."
    if ! iptables -L GEO > /dev/null 2>&1; then
        iptables -N GEO
        iptables -I INPUT -j GEO
        iptables -I OUTPUT -j GEO
        iptables -I FORWARD -j GEO
    fi
}

# Function to flush and reset iptables GEO chain
reset_iptables_chain() {
    echo "Flushing and resetting GEO chain..."
    iptables -D INPUT -j GEO
    iptables -D OUTPUT -j GEO
    iptables -D FORWARD -j GEO
    iptables -F GEO
    iptables -X GEO
    iptables -N GEO
}

# Function to apply GeoIP-based rules to iptables
apply_geoip_rules() {
    echo "Applying GeoIP rules..."

    # Block traffic from specific countries
    iptables -A GEO -m geoip --source-country $BLOCKED_COUNTRIES -j REJECT
    iptables -A GEO -m geoip --source-country $ADDITIONAL_BLOCKED_COUNTRIES -j REJECT
    iptables -A GEO -m geoip --source-country $EXTRA_BLOCKED_COUNTRIES -j REJECT
    iptables -A GEO -m geoip --source-country $MORE_BLOCKED_COUNTRIES -j REJECT

    # Allow traffic from specific countries (e.g., Ukraine for FTP)
    iptables -A GEO -i $PUB_IF -p tcp --sport 1024:65535 -d $SERVER_IP --dport 21 -m geoip --src-cc UA -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A GEO -o $PUB_IF -p tcp -s $SERVER_IP --sport 21 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT

    # Allow Cpanel and SSH from Russia
    iptables -A GEO -i $PUB_IF -p tcp --sport 1024:65535 -d $SERVER_IP --dport 2083 -m geoip --src-cc RU -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A GEO -o $PUB_IF -p tcp -s $SERVER_IP --sport 2083 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT

    iptables -A GEO -i $PUB_IF -p tcp --sport 1024:65535 -d $SERVER_IP --dport 22 -m geoip --src-cc RU -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A GEO -o $PUB_IF -p tcp -s $SERVER_IP --sport 22 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
}

# Main Execution
update_geoip_data
initialize_iptables_chain
reset_iptables_chain
apply_geoip_rules

echo "GeoIP firewall rules applied successfully."

exit 0
