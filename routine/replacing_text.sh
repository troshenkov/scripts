#!/bin/bash
# ------------------------------------------------------------------------------
# PHP Domain Replacement Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script searches for all .php files inside the /home/ directory and 
#   replaces occurrences of a specific domain with a new one.
#
# Usage:
#   ./replace_php_domain.sh
#
# Features:
#   - Logs replaced files and any errors to /var/log/php_replace.log.
#
# Dependencies:
#   - `sed` (stream editor for modifying files).
#
# Exit Codes:
#   0 - Script executed successfully.
#   2 - Error during domain replacement.
#
# Example:
#   ./replace_php_domain.sh
# ------------------------------------------------------------------------------

# Old and new domain names
OLD_DOMAIN="xn--80acvotjdl7j.xn--p1ai"
NEW_DOMAIN="artmebius.com"

# Log file location
LOG_FILE="/var/log/php_replace.log"

echo "Starting PHP file domain replacement..." | tee -a "$LOG_FILE"

# Find and replace occurrences in all .php files under /home/
find /home/ -name '*.php' -type f | while read -r file; do
    if grep -q "$OLD_DOMAIN" "$file"; then
        sed -i "s/$OLD_DOMAIN/$NEW_DOMAIN/g" "$file"
        if [ $? -eq 0 ]; then
            echo "Updated: $file" | tee -a "$LOG_FILE"
        else
            echo "Error updating: $file" | tee -a "$LOG_FILE" >&2
            exit 2
        fi
    fi
done

echo "Replacement process completed." | tee -a "$LOG_FILE"

exit 0
