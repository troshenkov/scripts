#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)



EMAIL=your@mail.tld
LOG=MESSAGE

find /home/  -maxdepth 4 -type f -name error_log ! -empty -print >> ${LOG}  -exec cp /dev/null {} \;

if [ ! -z ${LOG} ] ; then

	cat ${LOG} | mailx -s "Error logs is written on `hostname` (`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`)" ${EMAIL};
	rm -f ${LOG};

fi

exit 0
