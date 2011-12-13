#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-12
# Starts telnet to a specific port at a specific time
# in seconds from now


if [ -z $TELNET_SH ]; then

TELNET_SH="gdb.telnet.sh"

sleep $3
xterm -e telnet $1 $2

fi
