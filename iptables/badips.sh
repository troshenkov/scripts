#!/bin/bash
# ===================================================================
# Script for Blocking IPs Reported on www.badips.com
# ===================================================================
#
# This script blocks IPs that have been reported to www.badips.com.
# It downloads a list of bad IPs and configures iptables to block them.
#
# Usage: Run this script daily, e.g., via cron.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Define variables
_ipt=/sbin/iptables                # Location of iptables
_input=badips.db                   # Name of database (will be downloaded with this name)
_pub_if=eth0                       # Public interface (e.g., eth0 or enp0s3)
_droplist=droplist                  # Name of chain in iptables (can be modified)
_service=any                        # Logged service (e.g., "any" or "ssh")
_age=2m                             # Age filter for IPs (e.g., 2 months)

# Function to download the bad IPs list from badips.com
download_bad_ips() {
    echo "Downloading bad IPs list from www.badips.com..."
    wget -qO- "http://www.badips.com/get/list/${_service}/3?age=${_age}" > $_input || { echo "$0: Unable to download IP list."; exit 1; }
}

# Function to set up the blacklist in iptables
setup_blacklist() {
    echo "Setting up the blacklist in iptables..."
    # Flush existing chain
    $_ipt --flush $_droplist
    # Create a new chain
    $_ipt -N $_droplist

    # Filter out comments and blank lines, then add IPs to the blacklist
    while read -r ip; do
        if [[ -n "$ip" && "$ip" != \#* ]]; then  # Skip comments and empty lines
            $_ipt -A $_droplist -i ${_pub_if} -s "$ip" -j LOG --log-prefix "Drop Bad IP List"
            $_ipt -A $_droplist -i ${_pub_if} -s "$ip" -j DROP
        fi
    done < $_input
}

# Function to apply the blacklist to iptables
apply_blacklist() {
    echo "Applying the blacklist to iptables..."
    $_ipt -I INPUT -j $_droplist
    $_ipt -I OUTPUT -j $_droplist
    $_ipt -I FORWARD -j $_droplist
}

# Main execution
download_bad_ips
setup_blacklist
apply_blacklist

echo "Bad IPs blocking completed."

exit 0
