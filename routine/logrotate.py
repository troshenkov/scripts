#!/usr/bin/env python3
# ------------------------------------------------------------------------------
# Log Rotation Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
#
# Description:
#   This script rotates log files when they exceed a specified size.
#   It retains a specified number of rotated log files.
#
# Usage:
#   ./logrotate.py <file.log> <size_in_kb> <limit>
#
# Features:
#   - Checks if the log file exists before rotating.
#   - Renames old logs by shifting indices (e.g., file.log_1 → file.log_2).
#   - Clears the main log file after rotation.
#
# Dependencies:
#   - Python 3
#
# Exit Codes:
#   0 - Script executed successfully.
#   1 - Invalid usage (missing arguments or incorrect input).
#
# Example:
#   ./logrotate.py /var/log/myapp.log 1024 5
#
# ------------------------------------------------------------------------------

import os
import sys
import shutil

# Validate arguments
if len(sys.argv) < 4:
    print("Error: Missing arguments!")
    print("Usage: logrotate.py <file.log> <size_in_kb> <limit>")
    sys.exit(1)

file_name = sys.argv[1]
limit_size = int(sys.argv[2])
logs_number = int(sys.argv[3])

# Check if log file exists
if os.path.isfile(file_name):
    logfile_size = os.stat(file_name).st_size / 1024  # Convert size to KB

    if logfile_size >= limit_size:
        if logs_number > 0:
            for currentFileNum in range(logs_number, 0, -1):
                src = f"{file_name}_{currentFileNum - 1}" if currentFileNum > 1 else file_name
                dst = f"{file_name}_{currentFileNum}"

                if os.path.isfile(src):
                    shutil.copyfile(src, dst)
                    print(f"Copied: {src} → {dst}")

        # Clear the main log file
        open(file_name, 'w').close()
        print(f"Cleared: {file_name}")

print("Log rotation completed.")
sys.exit(0)

