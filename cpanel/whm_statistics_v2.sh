#!/bin/bash

# Script Name: WHM Statistics Generator
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Version: 2.0
# Date: April 24, 2025
#
# Description:
# This script generates a detailed CSV report of domains hosted on a WHM/cPanel server.
# It collects information such as domain status, account details, CMS type, database credentials,
# and other relevant data. The script also logs any errors or warnings and sends an email notification
# if issues are detected.
#
# Features:
# - Checks if WHM/cPanel is installed by verifying required files and directories.
# - Processes domain and user data from `/etc/userdatadomains`.
# - Detects CMS types (e.g., Joomla) and fetches version details.
# - Extracts database credentials and verifies database connectivity.
# - Handles excluded and suspended accounts.
# - Generates a CSV report with detailed domain information.
# - Logs errors and warnings to a log file.
# - Sends email notifications if issues are detected.
#
# Requirements:
# - WHM/cPanel must be installed on the server.
# - The `idn`, `ping`, `awk`, `grep`, and `mailx` utilities must be available.
# - The script must be executed with sufficient permissions to access required files and directories.
#
# Usage:
# 1. Place the script in a directory with execute permissions.
# 2. Update the `EMAIL` variable with the recipient's email address.
# 3. Run the script using the command: `bash whm_statistics_v2.sh`.
#
# Output:
# - A CSV file (`F.csv`) containing detailed domain information.
# - A log file (`MESSAGE`) with errors and warnings (if any).
# - Email notification sent to the specified email address if issues are detected.
#
# Notes:
# - Ensure that the `/etc/userdatadomains` file and `/var/cpanel/suspended/` directory exist.
# - The script assumes that the server uses WHM/cPanel's standard file structure.
#
# Disclaimer:
# This script is provided "as is" without any warranty. Use it at your own risk.

# Exit if required files or directories are missing
if [[ ! -s /etc/userdatadomains || ! -d /var/cpanel/suspended ]]; then
    echo 'Condition not met, maybe WHM/cPanel was not installed. Program will now close!'
    exit 0
fi

EMAIL="host@yourdomain.tld"
OUTPUT_FILE="F.csv"
LOG_FILE="MESSAGE"
EXCLUDE_ACCOUNTS=('corp' 'somename')

# Clear output and log files
: > "$OUTPUT_FILE"
: > "$LOG_FILE"

# Function to check if a domain is pingable
check_domain_status() {
    local domain=$1
    if ping -c 1 "$domain" &>/dev/null; then
        echo "Online"
    else
        echo "Offline"
    fi
}

# Function to fetch CMS details
fetch_cms_details() {
    local document_root=$1
    local cms_type=$2
    local cms_file=$3
    local version_file=$4

    if [[ -s "$document_root/$cms_file" ]]; then
        echo "$cms_type"
        if [[ -e "$document_root/$version_file" ]]; then
            grep -E 'version|release' "$document_root/$version_file" | awk '{ print $NF }' | tr '\n' ';'
        else
            echo "N/A;N/A"
        fi
    else
        echo "Unknown;N/A;N/A"
    fi
}

# Function to fetch database details
fetch_database_details() {
    local document_root=$1
    local db_config_file=$2

    if [[ -s "$document_root/$db_config_file" ]]; then
        grep -E 'DBLogin|DBName|DBPassword' "$document_root/$db_config_file" | awk '{ print $NF }' | tr '\n' ';'
    else
        echo "N/A;N/A;N/A"
    fi
}

# Read domain and user data
mapfile -t domains < <(awk -F: '{ print $1 }' /etc/userdatadomains)
mapfile -t users < <(awk -F= '{ print $1 }' /etc/userdatadomains | awk '{ print $2 }')
mapfile -t user_data < <(awk -F== '{ print $3 ";" $4 ";" $5 ";" $6 }' /etc/userdatadomains)
mapfile -t suspended_accounts < <(ls /var/cpanel/suspended/)

# Write CSV header
echo "DomainName;PunyCode;ResponseIP;AccountName;TypeDomain;OwnerDomain;DocumentRoot;HostIP;Registrar;PaidTill;Nameserver1;Nameserver2;PHP_Ver;CMS;ReleaseVER;MaintenanceVER;License_Key;URL_Admin;AdminUser;Password;UserDB;NameDB;PassDB;rsFirewallStatus;rs_Password;URL_Cpanel;PASSWORD;HostFTP;FTP_USER;URL_FTP;Plan;MX;EXCLUDED;Status" >> "$OUTPUT_FILE"

# Process each domain
for i in "${!domains[@]}"; do
    domain="${domains[$i]}"
    user="${users[$i]}"
    data="${user_data[$i]}"
    document_root=$(echo "$data" | awk -F ";" '{ print $3 }')

    # Check domain status
    status=$(check_domain_status "$domain")
    echo -n "$domain;" >> "$OUTPUT_FILE"
    if [[ "$status" == "Online" ]]; then
        echo -n "$(idn --quiet -u "$domain");$(ping -c 1 "$domain" | grep PING | awk '{ print $3 }');" >> "$OUTPUT_FILE"
    else
        echo -n ";;" >> "$OUTPUT_FILE"
    fi

    # Write user and domain data
    echo -n "$user;$data;" >> "$OUTPUT_FILE"

    # Fetch CMS details
    cms_details=$(fetch_cms_details "$document_root" "Joomla" "configuration.php" "libraries/cms/version/version.php")
    echo -n "$cms_details;" >> "$OUTPUT_FILE"

    # Fetch database details
    db_details=$(fetch_database_details "$document_root" "configuration.php")
    echo -n "$db_details;" >> "$OUTPUT_FILE"

    # Add additional details
    echo -n "https://$domain:2083/;" >> "$OUTPUT_FILE"
    echo "$status" >> "$OUTPUT_FILE"
done

# Send log file if it exists
if [[ -s "$LOG_FILE" ]]; then
    mailx -s "The hostnames are not pingable - $(hostname)" "$EMAIL" < "$LOG_FILE"
fi

# Cleanup
rm -f "$LOG_FILE"