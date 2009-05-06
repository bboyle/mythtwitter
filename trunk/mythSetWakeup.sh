#!/bin/sh

# $1 is the first argument to the script. It is the time in seconds since 1970
# this is defined in mythtv-setup with the time_t argument

# http://www.mythtv.org/wiki/ACPI_Wakeup#Integrate_into_mythTV_2

# We pass the local time that we want to wake up as --date "$1"
# we indicate we want it reported as UTC time with -u, and
# we indicate we want it reported as seconds since epoch with +%s.
SECS=`date -u --date $1 +%s`

echo 0 > /sys/class/rtc/rtc0/wakealarm      #this clears your alarm
echo $SECS > /sys/class/rtc/rtc0/wakealarm     #this writes your alarm
