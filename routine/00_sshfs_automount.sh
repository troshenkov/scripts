#!/bin/bash

# /etc/pm/sleep.d/00_sshfs_automount.sh

# Unmount all sshfs mountpoints before suspending/hibernating
# to prevent hanging sshfs after resume/thaw

case $1 in
hibernate | suspend)
mountpoint_count=$(egrep -c '(/[^ ]+) fuse.sshfs' /etc/mtab)
	if [ $mountpoint_count -gt 0 ]; then
		mountpoints=($(awk '/(\/[^ ]+) fuse.sshfs/ { print $2 }' /etc/mtab))
		for element in  $(seq 0 $((${#mountpoints[@]} - 1)))
		do
			fusermount -u "${mountpoints[$element]}"
		done
	fi
;;
	thaw | resume )
		mount -a
		;;
	#   exit 0
	#   ;;
	esac
exit 0
