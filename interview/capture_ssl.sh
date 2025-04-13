#!/bin/bash
# -----------------------------------------------------------------------------
# Script: capture_ssl.sh
#
# Description:
#   This script captures the SSL server certificate details for a list of websites,
#   saves them as certificate files (.crt), and prints a message indicating success
#   or failure for each site. It uses OpenSSL to fetch and save the certificates.
#
# Requirements:
#   - Bash (Linux or macOS environment)
#   - OpenSSL (command-line tool for SSL/TLS operations)
#
# Usage:
#   Run the script directly:
#       ./capture_ssl.sh
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date: April 13, 2025
#
# -----------------------------------------------------------------------------
# Notes:
#   - The script loops through a predefined list of websites and fetches their SSL
#     certificates.
#   - It uses OpenSSL's `s_client` and `x509` commands to capture and save the certificates.
#   - The certificates are saved in the current directory with the website name as the filename.
#   - Filenames are sanitized to replace dots (.) with underscores (_).
# -----------------------------------------------------------------------------

# www.apple.com
# www.google.com
# www.facebook.com
# www.netflix.com
# www.yahoo.com

HOSTS=(
  www.apple.com
  www.google.com
  www.facebook.com
  www.netflix.com
  www.yahoo.com
)

# Loop through each host and capture its SSL certificate
for HOST in "${HOSTS[@]}"; do
  echo "Capturing certificate for $HOST..."
  
  # Capture the certificate and save it to a file
  CERT_FILE="${HOST//./_}.crt"
  if echo | openssl s_client -servername "$HOST" -connect "$HOST:443" 2>/dev/null | \
    openssl x509 -inform pem -noout -text > "$CERT_FILE"; then
    echo "Certificate saved as $CERT_FILE"
  else
    echo "Failed to capture certificate for $HOST" >&2
  fi
done

echo "All certificates have been processed."