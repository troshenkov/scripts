#!/bin/bash
# ------------------------------------------------------------------------------
# ClamAV Virus Scan & Email Alert Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script updates ClamAV virus definitions, scans web directories for malware, 
#   logs the scan results, and sends an email alert if a virus is found.
#
# Usage:
#   ./clamav_scan.sh
#
# Features:
#   - Updates ClamAV database before scanning.
#   - Recursively scans all public_html directories in /home/*/.
#   - Excludes specific directories from the scan.
#   - Logs scan results to /tmp/clam_scan.log.
#   - Sends an email alert with the log attached if malware is detected.
#
# Dependencies:
#   - ClamAV (freshclam, clamscan)
#   - mailx (for sending email alerts)
#
# Configuration:
#   - Set EMAIL and CC variables to specify recipients for alerts.
#   - Adjust scan exclusions as needed.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Example:
#   ./clamav_scan.sh
#
# ------------------------------------------------------------------------------

# Email configuration
EMAIL="your@mail.tld"
CC="some@mail.tld"

# Log file path
LOG="/tmp/clam_scan.log"

# Remove the old log file if it exists
rm -f "${LOG}"

# Function to check for virus detections and send an email alert
check_scan() {
    if grep -q "FOUND" "${LOG}"; then
        SERVER_IP=$(ip -4 addr show eth0 | awk '/inet /{print $2}' | cut -d/ -f1)
        HOSTNAME=$(hostname)
        echo "The log file has been attached at $(date)" | mailx -s \
            "VIRUS detected on ${HOSTNAME} (${SERVER_IP})" -a "${LOG}" -c "${CC}" "${EMAIL}"
    fi
}

# Update ClamAV database
freshclam -v

# Perform the scan, excluding specific directories and logging output
clamscan --exclude-dir=/home/somedir --max-dir-recursion=200 -i -r /home/*/public_html/ --log="${LOG}" > /dev/null

# Check the scan results and send an alert if needed
check_scan

exit 0
