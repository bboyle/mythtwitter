#!/bin/sh

# $1 is the first argument to the script. It is the time in seconds since 1970
# this is defined in mythtv-setup with the time_t argument
# http://www.mythtv.org/wiki/ACPI_Wakeup#Integrate_into_mythTV_2

echo 0 > /sys/class/rtc/rtc0/wakealarm      #this clears your alarm
echo $1 > /sys/class/rtc/rtc0/wakealarm     #this writes your alarm
