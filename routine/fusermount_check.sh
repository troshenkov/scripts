#!/bin/bash
# ------------------------------------------------------------------------------
# SSHFS Connection Monitor & Auto-Recovery Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# Description:
#   This script checks the SSHFS connection to a remote backup server.
#   If the connection is lost, it attempts to remount the backup directory.
#   Logs events and sends an email notification if issues occur.
#
# Usage:
#   ./sshfs_monitor.sh
#
# Features:
#   - Checks if SSHFS is mounted.
#   - Attempts auto-recovery if disconnected.
#   - Logs connection status and errors.
#   - Sends an email alert on failures.
#
# Dependencies:
#   - SSHFS
#   - mailx (for email notifications)
#
# Configuration:
#   - Set USER, B_DIR, B_HOST, and EMAIL as needed.
#   - Adjust the log file path if required.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Example:
#   ./sshfs_monitor.sh
#
# ------------------------------------------------------------------------------

# Variables
USER='u82225'
B_DIR='/mnt/backup'
B_HOST='your-backup-server.tld'
EMAIL='your@mail.tld'
LOG_FILE="/var/log/sshfs_monitor.log"

# Load FUSE module
modprobe fuse 2>/dev/null || echo "[$(date)] - Warning: Failed to load fuse module" >> "$LOG_FILE"

# Ensure backup directory exists
mkdir -p "$B_DIR"

# Check if SSHFS is mounted
if ! mountpoint -q "$B_DIR"; then
    fusermount -u "$B_DIR" 2>/dev/null
    echo "[$(date)] - Lost connection to $B_HOST, attempting reconnect..." | tee -a "$LOG_FILE"

    # Attempt to remount
    sshfs -o reconnect "$USER@$B_HOST:/" "$B_DIR"

    # Verify successful mount
    if mountpoint -q "$B_DIR"; then
        echo "[$(date)] - Successfully reconnected to $B_HOST" | tee -a "$LOG_FILE"
    else
        echo "[$(date)] - ERROR: Failed to reconnect to $B_HOST" | tee -a "$LOG_FILE"
        echo -e "Subject: [ALERT] SSHFS Mount Issue on $(hostname)\n\n$(cat "$LOG_FILE")" | sendmail "$EMAIL"
    fi
fi

exit 0

