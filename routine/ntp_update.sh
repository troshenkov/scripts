#!/bin/bash
# ------------------------------------------------------------------------------
# NTP Time Synchronization Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# Description:
#   This script forces time synchronization with an NTP server and updates
#   the system's hardware clock (RTC).
#
# Usage:
#   ./ntp_update.sh
#
# Features:
#   - Synchronizes system time with an NTP server.
#   - Updates the hardware clock to ensure time consistency.
#   - Logs errors and status messages.
#
# Dependencies:
#   - ntpdate (or chrony as an alternative)
#   - hwclock (for RTC updates)
#
# Exit Codes:
#   0 - Success
#   1 - Failed to synchronize time
#
# Example:
#   ./ntp_update.sh
#
# ------------------------------------------------------------------------------

NTP_SERVER="pool.ntp.org"
LOG_FILE="/var/log/ntp_update.log"

# Ensure the script runs with root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    exit 1
fi

echo "Starting NTP synchronization..." | tee -a "$LOG_FILE"
if ntpdate "$NTP_SERVER" > /dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Time synchronized successfully with $NTP_SERVER" | tee -a "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Failed to synchronize time with $NTP_SERVER" | tee -a "$LOG_FILE"
    exit 1
fi

# Update hardware clock
hwclock --systohc --localtime
echo "$(date '+%Y-%m-%d %H:%M:%S') - Hardware clock updated successfully." | tee -a "$LOG_FILE"

exit 0
