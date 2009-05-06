#!/bin/sh

# Check to see if anyone is currently logged in. Return zero if not and 1 if so.
# Echoed text appears in log file.
# It can be removed and --quiet added to the grep command
# once you are satisfied that mythTV is working properly

# http://www.mythtv.org/wiki/ACPI_Wakeup#Integrate_into_mythTV_2

if
	last | grep "still logged in"
	then
		echo Someone is still logged in! Don\'t shut down!
		exit 1
	else
		echo Noone is logged in, ok to shut down.
		exit 0
fi
