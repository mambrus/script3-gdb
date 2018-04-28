#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-05-12

if [ -z $CONNECT_SH ]; then

CONNECT_SH="connect.sh"

function connect() {
	echo "Connecting to ${CON_HOST}:${CON_PORT}"
	if [ "X$(grep screen <<< $TERM)" == "X" ]; then
		# Run in screen.session only if not already in screen
		screen -S "$0" rlwrap nc ${CON_HOST} ${CON_PORT}
	else
		rlwrap nc ${CON_HOST} ${CON_PORT}
	fi
	echo "Connection ${CON_HOST}:${CON_PORT} ended"
}

source s3.ebasename.sh
if [ "$CONNECT_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	CONNECT_SH_INFO=${CONNECT_SH}
	#Source gdb.tap.sh to get defaults according to the same strategy first
	source gdb.tap.sh

	source .gdb.ui..connect.sh

	connect "$@"
	RC=$?

	exit $RC
fi

fi
