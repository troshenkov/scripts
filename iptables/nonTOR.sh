#!/bin/bash

# ===================================================================
# Block TOR Network IPs Using iptables
# ===================================================================
#
# This script creates an iptables chain 'nonTOR' to block all IP addresses
# from the TOR network. The IPs are fetched from an external source and
# added to the iptables rules to prevent traffic from those IPs.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Define the path to the iptables command
IPT=/sbin/iptables

# Remove previous nonTOR chain rules if they exist
$IPT -D INPUT -j nonTOR
$IPT -D OUTPUT -j nonTOR
$IPT -D FORWARD -j nonTOR
$IPT -F nonTOR
$IPT -X nonTOR

# Create a new nonTOR chain
$IPT -N nonTOR

# URL to fetch the list of TOR network IPs
FILE=Tor_ip_list_ALL.csv

# Download the list of TOR IPs
wget -q http://torstatus.blutmagie.de/ip_list_all.php -O $FILE

# Add each IP from the downloaded file to the nonTOR chain to be dropped
while IFS= read -r ip; do
    $IPT -A nonTOR -s "$ip" -j DROP
done < $FILE

# Remove the temporary file after processing
rm -f $FILE

# Insert the nonTOR chain into INPUT, OUTPUT, and FORWARD chains
$IPT -I INPUT -j nonTOR
$IPT -I OUTPUT -j nonTOR
$IPT -I FORWARD -j nonTOR

# Print message indicating completion
echo "TOR IP addresses have been successfully blocked."

exit 0
