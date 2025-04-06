#!/bin/bash

# Script to find error logs, email them, and clear their contents
# ===================================================================
# Purpose:
#   - This script searches for non-empty 'error_log' files within a specified 
#     directory and sends an email with their contents.
#   - After sending the email, it clears the content of the error logs.
#
# Usage:
#   - Replace the `EMAIL` variable with your desired recipient email address.
#   - The script searches for error logs under /home/ up to a depth of 4.
#   - It sends an email with the contents of all error logs found, along with 
#     the hostname and IP address of the machine.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date Created: <Creation Date>
# Last Updated: <Last Update Date>
# ===================================================================

# Configuration
EMAIL="your@mail.tld"    # Replace with your email
LOG="error_log_message.txt"  # Log file to store error logs

# Search for non-empty error_log files and append their names to the log
find /home/ -maxdepth 4 -type f -name "error_log" ! -empty -print >> "${LOG}" -exec cp /dev/null {} \;

# Check if the log file is not empty and send an email
if [ -s "${LOG}" ]; then
    # Get the IP address of eth0 interface
    IP_ADDRESS=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
    
    # Send the log file via email
    cat "${LOG}" | mailx -s "Error logs are written on $(hostname) ($IP_ADDRESS)" "${EMAIL}"

    # Remove the log file after sending
    rm -f "${LOG}"
fi

exit 0
















