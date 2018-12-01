#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)

# "DatabaseMirror db.de.clamav.net" >>  /etc/freshclam.conf 

EMAIL=your@mail.tld
CC=some@mail.tld

LOG=/tmp/clam_scan.log

#WPATH="/usr/local/cpanel/3rdparty/bin"

rm -f ${LOG};

check_scan () {

 if [ `cat ${LOG} | grep FOUND | grep -v 0 | wc -l` != 0 ] ; then
	echo "The log file has been attached at `date`" |  mailx -s \
	"VIRUS at the `hostname` (`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`)" -a ${LOG} -c $CC ${EMAIL}
 fi

}

freshclam -v && clamscan --exclude-dir=/home/somedir --max-dir-recursion=200 -i -r /home/*/public_html/ --log=${LOG} > /dev/null

check_scan

exit 0

