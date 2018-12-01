#!/bin/bash

# Dmitry Troshenkov (troshenkov.d@gmail.com)
# This script checks sshfs connection, restore it if required and sends a warning log to email.

USER='u82225'

B_DIR='/mnt/backup'
B_HOST='your-backup-server.tld'
EMAIL='your@mail.tld'

modprobe fuse
test -d $B_DIR || mkdir -p $B_DIR
b_test=`df | grep $B_HOST`

if [ -z "$b_test" ] || [ ! -d $B_DIR ]; then

	fusermount -u $B_DIR
	echo Host $B_HOST has lost connection >> MESSAGE
	echo `date` >> MESSAGE
	echo 'try to fix' >> MESSAGE

	#
	sshfs -o reconnect $USER@$USER.$B_HOST:/ $B_DIR
	#

	echo 'result: ' `df | grep $B_HOST` >> MESSAGE 

	cat MESSAGE | mailx -s "Warning Check mount  on `hostname` (`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`)" ${EMAIL}
	rm MESSAGE

fi


exit 0
