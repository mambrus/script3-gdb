#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-12
# Starts telnet to a specific port at a specific time
# in seconds from now


if [ -z $TELNET_SH ]; then

XTELNET_GEOMETRY=${XTELNET_GEOMETRY-"600x350+0+0"}

TELNET_SH="gdb.telnet.sh"

PTS="date +%Y:%j:%T.%N"
function log_tap() {
	if [ "X$TAP_LOG" == "Xyes" ]; then
		echo -n "[$$] $($PTS) " >> $TAP_LOG_NAME
		echo "$@" >> $TAP_LOG_NAME
	fi
}

#Use screen in-between is available
SCREEN=$(which screen)
NC=$(which nc)
RLWRAP=$(which rlwrap)

sleep $3

if [ "X${NC}" != "X" ] && [ "X${RLWRAP}" != "X" ]; then
	log_tap "xterm ${XTELNET_GEOMETRY} -e ${SCREEN} rlwrap nc $1 $2"
	xterm ${XTELNET_GEOMETRY} -e ${SCREEN} rlwrap nc $1 $2
else
	log_tap "xterm ${XTELNET_GEOMETRY} -e ${SCREEN} telnet $1 $2"
	xterm ${XTELNET_GEOMETRY} -e ${SCREEN} telnet $1 $2
fi

fi
