#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-03-05
# Shell wraps tcp_tap to make it gdb.tap.sh

if [ -z $TAP_SH ]; then

TAP_SH="tap.sh"

# This script works as the basename command, except that it also
# ripps away everything in the name before the next but last '.'
# I.e. usage like:
# $ tap /some/path/pre.fix.myshell.sh
#   myshell.sh
#
# The script is a core part of the 'script3' script library

function tap() {
	echo "Shabang!"
	tcp_tap "$@"
}

source s3.ebasename.sh
if [ "$TAP_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.

	export TCP_TAP_EXEC="arm-elf-gdb"
	export TCP_TAP_PORT="6161"
	export TCP_TAP_LOG_PATH="/dev"
	export TCP_TAP_LOG_STDIN="null"
	export TCP_TAP_LOG_STDOUT="null"
	export TCP_TAP_LOG_STDERR="null"
	export TCP_TAP_LOG_PARENT="null"
	export TCP_TAP_LOG_CHILD="null"

	tap "$@"
	exit $?
fi

fi
