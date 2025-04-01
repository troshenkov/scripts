#!/bin/bash

# ------------------------------------------------------------------------------
# Apache Log Analysis Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script scans Apache log files in /usr/local/apache/domlogs, counts 
#   the number of unique POST requests, and prints files with more than 
#   a defined threshold.
#
# Usage:
#   ./apache_log_scan.sh
#
# Features:
#   - Scans all log files in /usr/local/apache/domlogs.
#   - Counts unique POST requests in each file.
#   - Displays files where unique POST requests exceed the defined threshold.
#
# Configuration:
#   - Modify `_COUNT` to set the detection threshold.
#
# Exit Codes:
#   0 - Script executed successfully.
#
# Dependencies:
#   - Requires standard Linux utilities (find, grep, sort, uniq, wc).
#
# Example:
#   ./apache_log_scan.sh
#
# ------------------------------------------------------------------------------

_COUNT=200  # Threshold for unique POST request detection

# Find and process each log file
find /usr/local/apache/domlogs -type f | while read -r log_file; do
    post_count=$(grep "POST" "$log_file" | sort | uniq -c | wc -l)
    
    if [ "$post_count" -gt "$_COUNT" ]; then
        echo -e "$post_count $log_file"
    fi
done

exit 0

