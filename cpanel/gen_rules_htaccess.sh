#!/bin/bash

# ===================================================================
# Script to Generate .htaccess File with Allowed IP Range for NNOV
# ===================================================================
#
# This script fetches an IP range from a configurable external source,
# filters out any lines containing a colon (removes IPv6 addresses),
# and generates an `.htaccess` file that allows access only from the
# specific IP addresses.
#
# The script:
# - Denies access from all IP addresses by default.
# - Allows access from specific IPs fetched from the external source.
#
# Improvements & Considerations:
# - Error handling if the curl request fails.
# - Logs any issues encountered during script execution.
# - Allows dynamic file output and configurable external URL.
#
# Usage:
# - Run this script with appropriate privileges.
# - Specify the output file (default: "nnov_htaccess").
# - Customize the URL for fetching IPs if needed.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Configuration - URL and Output File
URL="http://files.unn.ru/ixnn.txt"    # External URL for IP range
HTA="nnov_htaccess"                  # Default output file
LOGFILE="/var/log/nnov_htaccess.log"  # Log file location

# Functions

# Log function for logging success and errors
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> ${LOGFILE}
}

# Check if script has write permission to the destination file
check_permissions() {
    if [ ! -w "$(dirname "${HTA}")" ]; then
        log_message "Error: Insufficient permissions to write to the target directory."
        echo "Error: Insufficient permissions to write to the target directory."
        exit 1
    fi
}

# Fetch IP range and generate .htaccess file
generate_htaccess() {
    # Fetch the IP range from the external URL
    NNOV_IP_RANGE=$(curl -s ${URL} | grep -v ':')
    
    # Check if curl was successful
    if [ $? -ne 0 ]; then
        log_message "Error: Failed to fetch IP range from ${URL}."
        echo "Error: Failed to fetch IP range from ${URL}. Check your network connection or URL."
        exit 1
    fi
    
    # Check if the IP range is empty
    if [ -z "${NNOV_IP_RANGE}" ]; then
        log_message "Error: No IP addresses found in the range from ${URL}."
        echo "Error: No IP addresses found. The fetched data may be empty."
        exit 1
    fi
    
    # Clear existing .htaccess file or create a new one
    :> ${HTA}

    # Add default deny rules to the .htaccess file
    echo 'Order Deny,Allow' >> ${HTA}
    echo 'Deny from all' >> ${HTA}

    # Loop through the fetched IP range and add "Allow" rules
    for ip in ${NNOV_IP_RANGE}; do
        echo "Allow from ${ip}" >> ${HTA}
    done

    # Log success
    log_message "Successfully generated ${HTA} with allowed IP range."
    echo "Successfully generated ${HTA} with allowed IP range."
}

# Main Script Execution

check_permissions
generate_htaccess

exit 0
