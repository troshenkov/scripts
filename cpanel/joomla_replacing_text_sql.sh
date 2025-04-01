#!/bin/bash

# ===================================================================
# Script to Replace Text in Joomla Database for Different Versions
# ===================================================================
#
# This script updates the Joomla database to replace old domain names
# with the new domain across multiple tables.
#
# The script will:
# - Connect to each Joomla database defined in the configuration file.
# - Update relevant fields with the new domain name.
# - Handle multiple domains in a loop.
#
# Improvements:
# - Error handling for MySQL connections.
# - Logging for tracking changes and errors.
# - More efficient command usage.
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# ===================================================================

# Configurable variables
OLD_DOMAINS=("artmebius.ru" "artmebius.su" "артмёбиус.рф" "xn--80acvotjdl7j.xn--p1ai" "артмебиус.рф" "xn--80aclnrxldn.xn--p1ai")
NEW_DOMAIN="artmebius.com"
LOGFILE="/var/log/joomla_db_replace.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> ${LOGFILE}
}

# Function to fetch the configuration values from the files
get_config_value() {
    local key=$1
    find /home -maxdepth 3 -name "configuration.php" -exec grep -H "\$$key" {} \; | awk -F"'" '{print $4}'
}

# Fetch database credentials
DB_PREFIXES=($(get_config_value "dbprefix"))
USERS=($(get_config_value "user"))
DBS=($(get_config_value "db"))
PASSWORDS=($(get_config_value "password"))

# Check if there are any results from configuration extraction
if [ ${#DB_PREFIXES[@]} -eq 0 ] || [ ${#USERS[@]} -eq 0 ] || [ ${#DBS[@]} -eq 0 ] || [ ${#PASSWORDS[@]} -eq 0 ]; then
    log_message "Error: Failed to fetch configuration values."
    exit 1
fi

# Process each database connection
for ((n=0; n < ${#DB_PREFIXES[@]}; n++)); do
    for OLD_DOMAIN in "${OLD_DOMAINS[@]}"; do
        # Log the process
        log_message "Updating domain in database ${DBS[$n]} (prefix: ${DB_PREFIXES[$n]})"
        
        # Run MySQL commands to replace the old domain with the new one
        mysql -u"${USERS[$n]}" -p"${PASSWORDS[$n]}" "${DBS[$n]}" <<-EOF
            UPDATE ${DB_PREFIXES[$n]}modules SET content = REPLACE(content, "$OLD_DOMAIN", "$NEW_DOMAIN");
            UPDATE ${DB_PREFIXES[$n]}content SET introtext = REPLACE(introtext, "$OLD_DOMAIN", "$NEW_DOMAIN"), fulltext = REPLACE(fulltext, "$OLD_DOMAIN", "$NEW_DOMAIN");
            UPDATE ${DB_PREFIXES[$n]}menu SET title = REPLACE(title, "$OLD_DOMAIN", "$NEW_DOMAIN"), link = REPLACE(link, "$OLD_DOMAIN", "$NEW_DOMAIN");
EOF
        
        # Check if the command was successful
        if [ $? -eq 0 ]; then
            log_message "Successfully updated domain for $OLD_DOMAIN in database ${DBS[$n]}."
        else
            log_message "Error: Failed to update domain for $OLD_DOMAIN in database ${DBS[$n]}."
        fi
    done
done

log_message "Script execution completed."
exit 0
