#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)
# This script checks status of process, executes it if required and sends a warning log to email.
# Does not work for a process running by root.

EMAIL=your@mail.tld

for SERV in httpd dovecot exim mysql named nginx; do

	test=`ps aux | grep $SERV | grep -v root` 

	if [ -z "$test" ]; then
		echo `date +%x-%X`: "$SERV is not running! Run..." >> /var/log/runlog]
		/etc/init.d/$SERV start
		#service $SERV start
		echo "Service $SERV was restarted `date`" >> MESSAGE
	fi
done

if [ -f MESSAGE ] ; then
	cat MESSAGE | mailx -s "Warning RunCheck at the  `hostname` (`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`)" ${EMAIL}
	rm MESSAGE
fi

exit 0

