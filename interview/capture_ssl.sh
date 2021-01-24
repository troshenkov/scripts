#!/bin/bash

#--- Apple ----

# Capture SSL Server Certificate
# Scan through a list of websites, capture SSL Server Certificate security details, sort Certificates' data as per their validity, and export data file.

# *Websites sample*
# www.apple.com
# www.google.com
# www.facebook.com
# www.netflix.com
# www.yahoo.com


declare -a HOSTS=('www.apple.com', 'www.google.com', 'www.facebook.com', 'www.netflix.com', 'www.yahoo.com')

for ((n=0; n < ${#HOSTS[*]}; n++)) ; do  
  echo | openssl s_client -showcerts -servername ${HOSTS[$n]} -connect ${HOSTS[$n]}:443 2>/dev/null | \
        openssl x509 -inform pem -noout -text > ${HOSTS[$n]}.crt
done


