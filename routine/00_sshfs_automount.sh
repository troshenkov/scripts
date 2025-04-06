#!/bin/bash

# /etc/pm/sleep.d/00_sshfs_automount.sh
# Handles SSHFS mount/unmount on system suspend and resume

case "$1" in
    hibernate | suspend)
        # Unmount all SSHFS mountpoints before suspending/hibernating
        mapfile -t mountpoints < <(awk '$3 == "fuse.sshfs" {print $2}' /proc/mounts)
        
        if [ ${#mountpoints[@]} -gt 0 ]; then
            for mount in "${mountpoints[@]}"; do
                if command -v fusermount >/dev/null 2>&1; then
                    fusermount -u "$mount"
                else
                    echo "fusermount not found! Cannot unmount $mount."
                fi
            done
        fi
        ;;
    thaw | resume)
        # Re-mount all filesystems
        mount -a
        ;;
esac

exit 0
