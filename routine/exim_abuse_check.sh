#!/bin/bash

# Exim Abuse Check Script
# ===================================================================
# Purpose:
#   - This script checks the Exim mail queue and logs any abnormalities
#     in the mail queue if it exceeds a predefined threshold.
#   - If the mail queue exceeds the specified limit, it gathers information
#     from the Exim mail queue and the Exim main log to detect potential abuse.
#   - The script then emails the log contents and clears the log after emailing.
#
# Usage:
#   - Replace the `EMAIL` variable with your desired recipient email address.
#   - Set the desired threshold for mail queue size in `_COUNT`.
#   - The script will monitor the Exim mail queue and send an email alert 
#     when the threshold is exceeded.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date Created: <Creation Date>
# Last Updated: <Last Update Date>
# ===================================================================

# Dmitry Troshenkov (troshenkov.d@gmail.com)

# Configuration
EMAIL="you@domain.tld"  # Replace with your email
LOG="exim_abuse_log.txt"  # Log file to store Exim abuse details

# Max number of mail queues before considering it an abuse situation
_COUNT=50

# Get the current number of mail queues in Exim
_QUEUE=$(exim -bpr | grep "@" | wc -l)

# Check if the mail queue exceeds the defined threshold
if [ ${_QUEUE} -gt ${_COUNT} ]; then
    # Log the current queue size
    echo "Queue: ${_QUEUE}" >> ${LOG}
    
    # Log the unique senders in the queue
    echo $(exim -bpr | grep "@" | sort | uniq -c) >> ${LOG}
    
    # Separator
    echo "+++++++++++++++++++" >> ${LOG}
    
    # Log potential abuse based on max defers and failures per hour
    echo "Abuse:" >> ${LOG}
    echo $(cat /var/log/exim_mainlog | grep 'has exceeded the max defers and failures per hour' | awk '{ print $8 }' | sort | uniq -c) >> ${LOG}
    
    # Send the log file via email
    cat ${LOG} | mailx -s "Exim queue alert on $(hostname) ($(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}') )" ${EMAIL}
    
    # Remove the log file after sending
    rm -f ${LOG}
fi

exit 0
