#!/bin/bash

# ===================================================================
# Apply Spamhaus DROP List to Firewall (iptables)
# ===================================================================
#
# This script fetches the Spamhaus DROP list and applies the IP blocks 
# to iptables to prevent access from known malicious IPs.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Define variables
IPTABLES=/sbin/iptables
FILE="/tmp/drop.lasso"
URL="http://www.spamhaus.org/drop/drop.lasso"

# Remove any existing DROP list chain from iptables
$IPTABLES -D INPUT -j Spamhaus
$IPTABLES -D OUTPUT -j Spamhaus
$IPTABLES -D FORWARD -j Spamhaus
$IPTABLES -F Spamhaus
$IPTABLES -X Spamhaus

# Remove any existing downloaded list file
[ -f "$FILE" ] && rm -f "$FILE"

# Download the Spamhaus DROP list
cd /tmp
wget -q $URL -O "$FILE"

# Ensure the file was downloaded correctly
if [ ! -f "$FILE" ]; then
    echo "Error: Failed to download the Spamhaus DROP list."
    exit 1
fi

# Extract and filter valid IP blocks from the list
blocks=$(grep -v '^;' "$FILE" | awk '{ print $1 }')

# Create a new chain in iptables
$IPTABLES -N Spamhaus

# Loop through each IP block and apply DROP rules
for ipblock in $blocks; do
    # Apply DROP rule to each IP block
    $IPTABLES -A Spamhaus -s "$ipblock" -j DROP
done

# Add the Spamhaus chain to the INPUT, OUTPUT, and FORWARD chains
$IPTABLES -I INPUT -j Spamhaus
$IPTABLES -I OUTPUT -j Spamhaus
$IPTABLES -I FORWARD -j Spamhaus

# Clean up the downloaded list file
rm -f "$FILE"

echo "Done"
exit 0
