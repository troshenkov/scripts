i#!/bin/bash

# ===================================================================
# IP Address Validation Script
# ===================================================================
# Purpose:
#   - Validate IP addresses using a comprehensive regular expression.
#   - Process multiple IP addresses passed as arguments.
#
# Usage:
#   - ./script_name.sh <ip_address1> <ip_address2> ...
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Function to validate IP address
validate_ip() {
    local ip="$1"
    local pattern="^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$"
    if [[ "$ip" =~ $pattern ]]; then
        echo "IP address '$ip' is valid."
    else
        echo "IP address '$ip' is invalid."
    fi
}

# Main script execution
if [[ "$#" -gt 0 ]]; then
    for ip in "$@"; do
        validate_ip "$ip"
    done
else
    echo "No IP addresses provided. Usage: $0 <ip_address1> <ip_address2> ..."
fi
