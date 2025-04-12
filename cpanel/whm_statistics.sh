#!/bin/bash

# ------------------------------------------------------------------------------
# WHM/cPanel Domain Statistics Script
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Description:
#   This script collects statistics about domains hosted on a WHM/cPanel server.
#   It generates a CSV file with detailed information about each domain, including
#   its status, registrar, hosting plan, and CMS details.
#
# Usage:
#   ./whm_statistics.sh
#
# Configuration:
#   - EMAIL: Email address to send logs if issues are detected.
#   - EXCLUDE: Array of accounts to exclude from processing.
#
# Dependencies:
#   - whois, dig, idn, mysql, mailx
#
# Notes:
#   - Ensure the script is run with appropriate permissions to access WHM/cPanel files.
# ------------------------------------------------------------------------------

# Configuration
EMAIL="host@yourdomain.tld"
OUTPUT_FILE="F.csv"
MESSAGE_FILE="MESSAGE"
EXCLUDE=('corp' 'somename')

# Initialize files
initialize_files() {
    : > "$OUTPUT_FILE"
    : > "$MESSAGE_FILE"
}

# Check prerequisites
check_prerequisites() {
    if [[ ! -s /etc/userdatadomains || ! -d /var/cpanel/suspended ]]; then
        echo 'Condition not met, maybe WHM/cPanel was not installed. Program will now close!'
        exit 1
    fi
}

# Write CSV header
write_csv_header() {
    echo -e "DomainName;PunyCode;ResponseIP;AccountName;TypeDomain;OwnerDomain;DocumentRoot;HostIP;Registrar;PaidTill;Nameserver1;Nameserver2;PHP_Ver;CMS;ReleaseVER;MaintenanceVER;License_Key;URL_Admin;AdminUser;Password;UserDB;NameDB;PassDB;rsFirewallStatus;rs_Password;URL_Cpanel;PASSWORD;HostFTP;FTP_USER;URL_FTP;Plan;MX;EXCLUDED;Status" >> "$OUTPUT_FILE"
}

# Process a single domain
process_domain() {
    local domain="$1"
    local user="$2"
    local user_data="$3"

    local excluded=0
    local status=0

    # Write domain name
    echo -n "$domain;" >> "$OUTPUT_FILE"

    # Check if domain is pingable
    if ! ping -c 1 "$domain" &>/dev/null; then
        echo "No ping to $domain" >> "$MESSAGE_FILE"
        echo -n ";;" >> "$OUTPUT_FILE"
        status=0
    else
        # Get PunyCode and ResponseIP
        echo -n "$(idn --quiet -u "$domain");" >> "$OUTPUT_FILE"
        echo -n "$(ping -c 1 "$domain" | grep PING | awk -F'[()]' '{ print $2 }');" >> "$OUTPUT_FILE"
        status=1
    fi

    echo -n ";" >> "$OUTPUT_FILE"

    # Write account name
    echo -n "$user;" >> "$OUTPUT_FILE"

    # Write user data
    echo -n "$user_data;" >> "$OUTPUT_FILE"

    # Extract document root and domain type
    local document_root
    local type_domain
    document_root=$(echo "$user_data" | awk -F ";" '{ print $3 }')
    type_domain=$(echo "$user_data" | awk -F ";" '{ print $1 }')

    # Get registrar and paid-till data
    local whois_data
    whois_data=$(whois -h whois.tcinet.ru "$domain" | grep -E 'registrar|paid-till' | awk '{ print $2 }' | tr '\n' ';')
    echo -n "${whois_data:-;;}" >> "$OUTPUT_FILE"

    # Process main domains
    if [[ $type_domain == "main" ]]; then
        # Check if domain is suspended
        for suspended in "${_susd[@]}"; do
            if [[ "$user" == "$suspended" ]]; then
                status=2
                break
            fi
        done

        # Check if account is excluded
        for excluded_account in "${EXCLUDE[@]}"; do
            if [[ "$user" == "$excluded_account" ]]; then
                excluded=1
                break
            fi
        done

        # Get nameservers
        echo -n "$(dig +short "$domain" ns | sed -n 1p);" >> "$OUTPUT_FILE"
        echo -n "$(dig +short "$domain" ns | sed -n 2p);" >> "$OUTPUT_FILE"

        # Get PHP version
        if [[ -f "/home/$user/.cl.selector/defaults.cfg" ]]; then
            echo -n "$(grep 'php=' "/home/$user/.cl.selector/defaults.cfg" | cut -d= -f2);" >> "$OUTPUT_FILE"
        else
            echo -n "$(php -v | grep -oP '^PHP \K[0-9]+\.[0-9]+\.[0-9]+');" >> "$OUTPUT_FILE"
        fi
    else
        echo -n ";;;;;;;;;;;;;;;;;;;;;;" >> "$OUTPUT_FILE"
    fi

    # Write excluded status
    echo -n "$excluded;" >> "$OUTPUT_FILE"

    # Write domain status
    case "$status" in
        0) echo "Offline" >> "$OUTPUT_FILE" ;;
        1) echo "Online" >> "$OUTPUT_FILE" ;;
        2) echo "Suspended" >> "$OUTPUT_FILE" ;;
        *) echo "Unknown" >> "$OUTPUT_FILE" ;;
    esac
}

# Validate CSV file consistency
validate_csv() {
    local consistency
    consistency=$(awk -F\; '{print NF-1}' "$OUTPUT_FILE" | uniq -c | wc -l)
    if [[ $consistency -ne 1 ]]; then
        echo "=======================================================================" >> "$MESSAGE_FILE"
        echo "CSV file corrupted" >> "$MESSAGE_FILE"
    fi
}

# Send log via email if MESSAGE_FILE is not empty
send_logs() {
    if [[ -s "$MESSAGE_FILE" ]]; then
        sed -i -e 's/\r//g' "$MESSAGE_FILE"
        mailx -s "The hostnames are not pingable - $(hostname)" "$EMAIL" < "$MESSAGE_FILE"
    fi
}

# Cleanup temporary files
cleanup() {
    rm -f "$MESSAGE_FILE"
}

# Main script execution
main() {
    initialize_files
    check_prerequisites
    write_csv_header

    # Read data from files
    mapfile -t _dname < <(awk -F: '{ print $1 }' /etc/userdatadomains)
    mapfile -t _duser < <(awk -F= '{ print $1 }' /etc/userdatadomains | awk '{ print $2 }')
    mapfile -t _user_data < <(awk -F== '{ print $3 ";" $4 ";" $5 ";" $6 }' /etc/userdatadomains)
    mapfile -t _susd < <(ls /var/cpanel/suspended/)

    # Process each domain
    for ((n = 0; n < ${#_dname[@]}; n++)); do
        process_domain "${_dname[$n]}" "${_duser[$n]}" "${_user_data[$n]}"
    done

    validate_csv
    send_logs
    cleanup
}

main