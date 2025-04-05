#!/bin/sh
# ===================================================================
# Flexible Updating of Domain Blacklist
# ===================================================================
#
# This script updates the DNS filter chain with new domain blacklist rules.
# It fetches the latest rules from a GitHub repository and applies them to
# the iptables chain for DNS filtering.
#
# Usage: Run periodically to keep the DNS filter chain updated.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Configuration
IPCHAIN=dnsfilter            # The iptables chain to use
TARGET=DROP                  # Action to take when a match is made (DROP, REJECT, LOG, or custom CHAINNAME)
BACKUP_DIR=/tmp              # Directory to store backups

# Function to initialize the iptables chain if it doesn't exist
initialize_chain() {
    echo "Checking if chain '$IPCHAIN' exists..."
    if [ "$(iptables -L $IPCHAIN | wc -l)" -lt 1 ]; then
        echo "Chain '$IPCHAIN' does not exist. Creating it..."
        iptables -N $IPCHAIN
        iptables -I INPUT -p udp --dport 53 -j $IPCHAIN
    fi
}

# Function to back up iptables rules
backup_iptables() {
    echo "Backing up iptables rules..."
    iptables-save > "${BACKUP_DIR}/iptables_rules_$(date +%Y%m%d_%H%M%S).txt"
    iptables -n -L $IPCHAIN > "${BACKUP_DIR}/iptables_old.txt"
    old_count=$(wc -l < "${BACKUP_DIR}/iptables_old.txt")
    echo "Rules in '$IPCHAIN' before update: $(($old_count - 2))"
}

# Function to flush the iptables chain and apply the default action
flush_and_reset_chain() {
    echo "Flushing chain '$IPCHAIN' and setting default action to RETURN..."
    iptables -F $IPCHAIN
    iptables -A $IPCHAIN -j RETURN
}

# Function to update the rules from GitHub
update_blacklist() {
    echo "Fetching new rules from GitHub..."
    curl -s https://raw.github.com/smurfmonitor/dns-iptables-rules/master/domain-blacklist.txt | while read line; do
        RULE=$(echo "$line" | sed -e "s/INPUT/$IPCHAIN/" -e "s/-j DROP/-j $TARGET/")
        eval $RULE
    done
}

# Function to compare the old and new iptables rules
compare_rules() {
    iptables -n -L $IPCHAIN > "${BACKUP_DIR}/iptables_new.txt"
    new_count=$(wc -l < "${BACKUP_DIR}/iptables_new.txt")
    echo "Rules in '$IPCHAIN' after update: $(($new_count - 2))"
    diff "${BACKUP_DIR}/iptables_old.txt" "${BACKUP_DIR}/iptables_new.txt"
}

# Main execution
initialize_chain
backup_iptables
flush_and_reset_chain
update_blacklist
compare_rules

# Cleanup
rm -f "${BACKUP_DIR}/iptables_new.txt" "${BACKUP_DIR}/iptables_old.txt"

echo "Domain blacklist update completed."

exit 0
