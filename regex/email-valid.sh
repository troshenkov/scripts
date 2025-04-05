#!/bin/bash

# ===================================================================
# Email Validation Script
# ===================================================================
# Purpose:
#   - Validate email addresses using a comprehensive regular expression.
#   - Provide user feedback on the validity of the entered email.
#
# Usage:
#   - Run the script and input an email address when prompted.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Function to validate email
validate_email() {
    local email="$1"
    local pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    if [[ "$email" =~ $pattern ]]; then
        echo "Valid email address: $email"
    else
        echo "Invalid email address: $email"
    fi
}

# Main script execution
echo "Enter an email address to validate:"
read user_email
validate_email "$user_email"
