#!/bin/sh

# Force time synchronisation with NTP
ntpdate pool.ntp.org > /dev/null 2>&1

# Set the hardware clock (RTC)
hwclock --systohc --localtime

exit 0

