#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)
# This script makes some global Apache modifications on the WHM/cPanel.

########################
# To /usr/local/apache/conf/httpd.conf need add
# Include "/usr/local/apache/conf/includes/admin-acc.conf"
#######################

#NNOV_IP_RANGE=`curl http://files.unn.ru/ixnn.txt | grep -v ':'`

FILE=/usr/local/apache/conf/includes/admin-acc.conf
echo -e "<Location /administrator>" > $FILE
echo -e "  Order deny,allow" >> $FILE
echo -e "  Allow from all" >> $FILE
#for IP in $NNOV_IP_RANGE; do echo -e "  Allow from" $IP >> $FILE; done
echo -e "</Location>" >> $FILE

########################
# To /usr/local/apache/conf/httpd.conf need add
# Include "/usr/local/apache/conf/includes/stories.conf"
#######################

FILE=/usr/local/apache/conf/includes/stories.conf
echo -e '<LocationMatch "/stories/.*(?i)\.(php|php3?|phtml)$">' > $FILE
echo -e "  order allow,deny" >> $FILE
echo -e "  deny from all" >> $FILE
echo -e "</LocationMatch>" >> $FILE

/usr/local/cpanel/bin/apache_conf_distiller --update
/usr/local/cpanel/bin/build_apache_conf
/etc/init.d/httpd restart

exit 0

