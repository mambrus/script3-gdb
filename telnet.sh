#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-12
# Starts telnet to a specific port at a specific time
# in seconds from now


if [ -z $TELNET_SH ]; then

XTELNET_GEOMETRY=${XTELNET_GEOMETRY-"600x350+0+0"}

TELNET_SH="gdb.telnet.sh"

#Use screen in-between is available
SCREEN=$(which screen)

sleep $3
xterm -geometry ${XTELNET_GEOMETRY} -e ${SCREEN} telnet $1 $2

fi
