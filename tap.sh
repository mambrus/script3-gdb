#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-03-05
# Shell wraps tcp_tap to make it customized program wit tap-ability Use this
# file "as-is" or as a template for your own wrappers.
#
# Mandatory settings are TCP_TAP_EXEC & TCP_TAP_PORT, which need to be
# unique for each program you intend to extend with a "tap". For profile
# settings TCP_TAP_PROFILE is preferred to have set.


if [ -z $TAP_SH ]; then
TAP_SH=gdb.tap.sh

#If overloaded, set to read last
if [ "X${TCP_TAP_PROFILE}" != "X" ]; then
	TCP_TAP_PROFILE_SPECIAL=$TCP_TAP_PROFILE
fi

#Real profile structure is always predicable
TCP_TAP_PROFILE=.${TAP_SH}_rc

PTS="date +%Y:%j:%T.%N"

function tap() {
	exec tcp_tap "$@"
}

function log_tap() {
	if [ "X$TAP_LOG" == "Xyes" ]; then
		echo -n "$($PTS) " >> $TAP_LOG_NAME
		echo "$@" >> $TAP_LOG_NAME
	fi
}

# Test for environment settings at various locations before falling back on
# hard-coded defaults. Note that all settings are merged. I.e. you can
# overload in steps and have finer adjustments further out in the leaf and
# defaults further up. Or you can just overload everything in the leaf.

# Presidency tree:

# * Content of custom pre-set $TCP_TAP_PROFILE
# * Content of $TCP_TAP_PROFILE in local directory
# * ~/$TCP_TAP_PROFILE
# * Pre-set environment variables
# * Hard coded defaults in this file

if [ -f "/etc/${TCP_TAP_PROFILE}" ]; then
	F="/etc/${TCP_TAP_PROFILE}"
	source $F
	TCP_TAP_READ_FROM="$TCP_TAP_READ_FROM,$F"
fi
if [ -f "${HOME}/${TCP_TAP_PROFILE}" ]; then
	F="${HOME}/${TCP_TAP_PROFILE}"
	echo "Hej!"
	source $F
	TCP_TAP_READ_FROM="$TCP_TAP_READ_FROM,$F"
fi
if [ -f "${TCP_TAP_PROFILE}" ]; then
	F="${TCP_TAP_PROFILE}"
	source $F
	TCP_TAP_READ_FROM="$TCP_TAP_READ_FROM,$F"
fi
if [ -f "${TCP_TAP_PROFILE_SPECIAL}" ]; then
	F="${TCP_TAP_PROFILE_SPECIAL}"
	source $F
	TCP_TAP_READ_FROM="$TCP_TAP_READ_FROM,$F"
fi

TCP_TAP_FIRST_PORT=${TCP_TAP_FIRST_PORT-"8080"}
TCP_TAP_XTERM_DELAY=${TCP_TAP_XTERM_DELAY-"1"}
TCP_TAP_CMD=${TCP_TAP_CMD-"gdb"}
TAP_LOG_NAME=${TAP_LOG_NAME-"/tmp/.${TAP_SH}.log"}
TAP_LOG=${TAP_LOG-"yes"}
TAP_SIDE_SESSION=${TAP_SIDE_SESSION-"no"}
TAP_SIDE_SESSION_EXEC=${TAP_SIDE_SESSION_EXEC-"gdb.telnet.sh"}
TCP_TAP_NICNAME=${TCP_TAP_NICNAME-"127.0.0.1"}

# Can be used by $TAP_SIDE_SESSION_EXEC
# Measure this with the 'xwininfo' command-line utility. Note that you
# embed -display here as well.
#export XTELNET_GEOMETRY=${XTELNET_GEOMETRY-"-geometry 114x58+10+49"}


#Number of other sessions already in use (port collision avoidance)
NR_INUSE=$(ps -Al | grep tcp_tap | wc -l)

if [ "$TAP_SH" == $( basename $0 ) ]; then
	#Not sourced, do something with this.

	log_tap "START wrapper: $0 $@"
	log_tap "Environment read from:"
	log_tap "   $(echo $TCP_TAP_READ_FROM | sed -e 's/,/\n   /g')"
	log_tap "Local variables:"
	log_tap "   TCP_TAP_FIRST_PORT=$TCP_TAP_FIRST_PORT"
	log_tap "   TCP_TAP_XTERM_DELAY=$TCP_TAP_XTERM_DELAY"
	log_tap "   TCP_TAP_CMD=$TCP_TAP_CMD"
	log_tap "   TAP_LOG_NAME=$TAP_LOG_NAME"
	log_tap "   TAP_LOG=$TAP_LOG"
	log_tap "   TAP_SIDE_SESSION=$TAP_SIDE_SESSION"
	log_tap "   TAP_SIDE_SESSION_EXEC=$TAP_SIDE_SESSION_EXEC"
	log_tap "   NR_INUSE=$NR_INUSE"
	log_tap "   TCP_TAP_PROFILE=$TCP_TAP_PROFILE"
	log_tap "   TCP_TAP_PROFILE_SPECIAL=$TCP_TAP_PROFILE_SPECIAL"

	if [ "X$TAP_SIDE_SESSION" == "Xyes" ]; then
		$TAP_SIDE_SESSION_EXEC localhost $TCP_TAP_PORT $TCP_TAP_XTERM_DELAY &
	fi

	export TCP_TAP_EXEC="$(which ${TCP_TAP_CMD})"
	export TCP_TAP_PORT=$(( TCP_TAP_FIRST_PORT + NR_INUSE ))
	export TCP_TAP_LOG_STDIN="/dev/null"
	export TCP_TAP_LOG_STDOUT="/dev/null"
	export TCP_TAP_LOG_STDERR="/dev/null"
	export TCP_TAP_LOG_PARENT="/dev/null"
	export TCP_TAP_LOG_CHILD="/dev/null"
	log_tap "Exported variables:"
	log_tap "	TCP_TAP_EXEC=$TCP_TAP_EXEC"
	log_tap "	TCP_TAP_PORT=$TCP_TAP_PORT"
	log_tap "	TCP_TAP_LOG_STDIN=$TCP_TAP_LOG_STDIN"
	log_tap "	TCP_TAP_LOG_STDOUT=$TCP_TAP_LOG_STDOUT"
	log_tap "	TCP_TAP_LOG_STDERR=$TCP_TAP_LOG_STDERR"
	log_tap "	TCP_TAP_LOG_PARENT=$TCP_TAP_LOG_PARENT"
	log_tap "	TCP_TAP_LOG_CHILD=$TCP_TAP_LOG_CHILD"
	log_tap "	XTELNET_GEOMETRY=$XTELNET_GEOMETRY"

	log_tap "START exec: $@"
	tap "$@"
	RC=$?
	log_tap "END exec($RC): $@"
	exit $?
fi

fi
