#!/bin/bash

# ===================================================================
# SSN Validation Script
# ===================================================================
# Purpose:
#   - Validate Social Security Numbers (SSNs) using a comprehensive regular expression.
#   - Process multiple SSNs passed as arguments.
#
# Usage:
#   - ./script_name.sh <SSN1> <SSN2> ...
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Function to validate SSN
validate_ssn() {
    local ssn="$1"
    local pattern="^(?!000|666|9\d{2})\d{3}-(?!00)\d{2}-(?!0000)\d{4}$"
    if [[ "$ssn" =~ $pattern ]]; then
        echo "SSN '$ssn' is valid."
    else
        echo "SSN '$ssn' is invalid."
    fi
}

# Main script execution
if [[ "$#" -gt 0 ]]; then
    for ssn in "$@"; do
        validate_ssn "$ssn"
    done
else
    echo "No SSNs provided. Usage: $0 <SSN1> <SSN2> ..."
fi
