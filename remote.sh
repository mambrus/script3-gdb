#!/bin/bash

# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2013-05-12

if [ -z $REMOTE_SH ]; then

REMOTE_SH="remote.sh"

function remote() {
		cat -- | \
		sed -e 's/\x1b.\x4b//g' | \
		sed -e 's/\x0d/\n/g'
}

source s3.ebasename.sh
if [ "$REMOTE_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	REMOTE_SH_INFO=${REMOTE_SH}
	source .gdb.ui..remote.sh

	remote "$@"
	RC=$?

	exit $RC
fi

fi
