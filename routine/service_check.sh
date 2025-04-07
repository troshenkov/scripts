#!/bin/bash

# ------------------------------------------------------------------------------
# Service Check and Restart Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script checks if specified services (e.g., httpd, dovecot, exim, etc.) 
#   are running. If any service is not running, it will attempt to start it and 
#   log the action to a file. An email alert will be sent if any service was 
#   restarted.
#
# Usage:
#   ./service_check.sh
#
# Features:
#   - Checks the status of predefined services.
#   - Restarts any service that is not running.
#   - Logs actions and sends email alerts.
#
# Dependencies:
#   - mailx (for sending email alerts)
#   - /etc/init.d/service (for restarting services)
#
# Configuration:
#   - Set EMAIL variable to specify the recipient for alerts.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Example:
#   ./service_check.sh
#
# ------------------------------------------------------------------------------

EMAIL="your@mail.tld"    # Set email for alerts
LOGFILE="/var/log/runlog" # Log file to store service status checks
TEMP_MESSAGE="/tmp/service_restart_message" # Temporary file for message

# List of services to check
SERVICES=("httpd" "dovecot" "exim" "mysql" "named" "nginx")

# Loop over each service in the list
for SERV in "${SERVICES[@]}"; do
    # Check if the service is running (excluding root-owned processes)
    test=$(ps aux | grep "$SERV" | grep -v "root" | grep -v "grep")

    if [ -z "$test" ]; then
        # Log service status
        echo "$(date +%x-%X): $SERV is not running! Attempting to start..." >> "$LOGFILE"
        /etc/init.d/$SERV start
        # Append service restart message
        echo "Service $SERV was restarted at $(date)" >> "$TEMP_MESSAGE"
    fi
done

# If there was a restart action, send an email notification
if [ -f "$TEMP_MESSAGE" ]; then
    hostname=$(hostname)
    ip_address=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1 }')
    mailx -s "Warning: Service Restart on $hostname ($ip_address)" "$EMAIL" < "$TEMP_MESSAGE"
    rm "$TEMP_MESSAGE"
fi

exit 0
