#
# MythShutdownCheck
#
# checks to see if any other user is
# logged in before idle shutdown
#
# returns "1" if yes, stopping shutdown
# returns "0" if ok to shutdown
#

if last | head | grep -q "pts/.*still logged in"   # check for active *remote* login?

then
	exit 1

else
	exit 0
fi
