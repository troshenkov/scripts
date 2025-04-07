#!/bin/bash

# ------------------------------------------------------------------------------
# Backup Script for Files Modified in the Last $DAYS_BACK Days
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script archives files in the specified directory that have been modified
#   in the last $DAYS_BACK days. The backup is stored in a tar.bz2 file in the
#   specified backup directory. Files already located in the backup directory are
#   excluded from the backup to avoid redundant backups.
#
# Usage:
#   ./user-backup.sh
#
# Configuration:
#   - FROM_DIR: The source directory to scan for files (default: /home/user).
#   - BACKUP_DIR: Directory where the backup tar file will be saved (default: /home/user-backup).
#   - DAYS_BACK: Number of days back to search for modified files (default: 5).
#
# Dependencies:
#   - tar: For creating the backup archive.
#
# Example:
#   ./user-backup.sh
#
# Notes:
#   - Ensure the FROM_DIR and BACKUP_DIR are properly set to your environment.
#   - The script creates a timestamped backup file in the format:
#     back_<DAYS_BACK>days_<YYYY-MM-DD_HH-MM-SS>.tar.bz2
#
# ------------------------------------------------------------------------------
# Script Start

# Configuration
DATE=$(date +%Y-%m-%d_%H-%M-%S)  # Better timestamp format
FROM_DIR=/home/user
BACKUP_DIR=/home/user-backup
DAYS_BACK=5

# Ensure backup directory exists
test -d "$BACKUP_DIR" || mkdir -p "$BACKUP_DIR"

# Find files modified in the last $DAYS_BACK days and archive them
find "$FROM_DIR" -maxdepth 1 -mtime -"$DAYS_BACK" \( \
    -name "*.xls" -o -name "*.docx" -o -name "*.txt" -o -name "*.pdf" \
    -o -name "*.doc" -o -name "*.odt" -o -name "*.rtf" -o -name "*.sxw" \
    -o -name "*.xml" -o -name "*.html" -o -name "*.ppt" -o -name "*.pps" \
\) -exec tar jcpf "$BACKUP_DIR/back_${DAYS_BACK}days_${DATE}.tar.bz2" --exclude="$BACKUP_DIR" {} \;

# Check if the tar command was successful and send confirmation message
if [ $? -eq 0 ]; then
    echo "Backup completed successfully: $BACKUP_DIR/back_${DAYS_BACK}days_${DATE}.tar.bz2"
else
    echo "Error occurred during the backup process!"
    exit 1
fi

exit 0
