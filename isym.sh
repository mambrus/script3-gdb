#!/bin/bash
# Author: Michael Ambrus (michael.ambrus@sonyericsson.com)
# 2011-05-27
# Take the first looking 32-bit hex decimal value on each line
# and convert it to info symbol <value> to be used in a gdb script

if [ -z $ISYM ]; then

ISYM="isym.sh"

function isym() {
	cat "${1}" | sed -e 's/\(.*\)\(0x[[:xdigit:]]\{8\}\)\(.*\)/info symbol \2/'
}

source s3.ebasename.sh
if [ "$ISYM" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	tty -s; ATTY="$?"
	ISATTY="$ATTY -eq 0"
	
	set -e
	set -u

	if [ ! $ISATTY ]; then
		#This is an piped input
		FILENAME="--"
	else
		if [ $# -ne 0 ]; then
			FILENAME="${1}"
		else
			echo "Syntax error: $ISYM [FILE] start [stop]" >&2
			exit 1
		fi
		if [ ! -f $FILENAME ]; then
			echo "Error: file not found [$FILENAME]" >&2
			exit 1
		fi

	fi

	isym "$FILENAME" "$@"
	exit $?
fi

fi

