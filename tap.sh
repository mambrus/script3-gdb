#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-03-05
# Shell wraps tcp-tap to make it customized program wit tap-ability Use this
# file "as-is" or as a template for your own wrappers.
#
# Usage:
# You use this wrapper exactly as the command you intend to wrap, i.e. all
# it's arguments passed as it would be the command itself with the exception
# that the command itself is not typed. Instead the environment variable
# TCP_TAP_EXEC is expected to be set, preferably in one of the environment
# files searched for.
#
# Note:
# No arguments are allowed to neither this script that doesn't belong to the
# command it wraps. All of that is managed via environment variables
# instead.
#
# Example:
# TCP_TAP_CMD=gdb
# TCP_TAP_PORT=1903
# tcp.sh program.elf
#
# Environment:
# Even though defaulting to "gdb" & "8085", TCP_TAP_CMD & TCP_TAP_FIRST_PORT
# environment variables should at least be set. The second needs to be
# unique for each program you intend to extend with a "tap". For profile
# settings TCP_TAP_PROFILE is preferred to have set. Preferably set all
# environment variables in one (or several) of the environment files
# searched for:
#
# * /etc/tcp_tap_profile.rc
# * ${HOME}/.tcp_tap_profile.rc
# * .tcp_tap_profile.rc
# * ${TCP_TAP_PROFILE}
#
# All of the above are sourced in order meaning you can make course settings
# on "top" and refine then to project and even site specific settings the
# further down in the list you go.
#
# Side sessions:
# A side session is typically a terminal console already connected to the
# wrapper whence started. This is started **before** the wrapped process is
# executed and therefore needs a small delay before it tries to attach. This
# is set by the variable TCP_TAP_XTERM_DELAY and typically needs to be
# tuned. If it's too fast, it will start just to exit immediately.


if [ -z $TAP_SH ]; then
TAP_SH=gdb.tap.sh

#If set, change name of variable and read last
if [ "X${TCP_TAP_PROFILE}" != "X" ]; then
	TCP_TAP_PROFILE_SPECIAL=$TCP_TAP_PROFILE
fi

#Real profile file is always known
TCP_TAP_PROFILE=${TAP_SH}_profile.rc

PTS="date +%Y:%j:%T.%N"

function tap() {
	exec tcp-tap "$@"
}

function log_tap() {
	if [ "X$TAP_LOG" == "Xyes" ]; then
		echo -n "[$$] $($PTS) " >> $TAP_LOG_NAME
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


TCP_TAP_HAS_READ_CONFIG_FROM=">>>>"
if [ -f "/etc/${TCP_TAP_PROFILE}" ]; then
	F="/etc/${TCP_TAP_PROFILE}"
	source $F
	TCP_TAP_HAS_READ_CONFIG_FROM="$TCP_TAP_HAS_READ_CONFIG_FROM: $F"
	#echo "1: ${TCP_TAP_HAS_READ_CONFIG_FROM}"
	#exit 0
fi
if [ -f "${HOME}/.${TCP_TAP_PROFILE}" ]; then
	F="${HOME}/.${TCP_TAP_PROFILE}"
	source $F
	TCP_TAP_HAS_READ_CONFIG_FROM="$TCP_TAP_HAS_READ_CONFIG_FROM: $F"
	#echo "2: ${TCP_TAP_HAS_READ_CONFIG_FROM}"
	#exit 0
fi
if [ -f "$(pwd)/.${TCP_TAP_PROFILE}" ]; then
	F="$(pwd)/.${TCP_TAP_PROFILE}"
	source $F
	TCP_TAP_HAS_READ_CONFIG_FROM="$TCP_TAP_HAS_READ_CONFIG_FROM: $F"
	#echo "3: ${TCP_TAP_HAS_READ_CONFIG_FROM}"
	#exit 0
fi
if [ -f "${TCP_TAP_PROFILE_SPECIAL}" ]; then
	F="${TCP_TAP_PROFILE_SPECIAL}"
	source $F
	TCP_TAP_HAS_READ_CONFIG_FROM="$TCP_TAP_HAS_READ_CONFIG_FROM: $F"
	#echo "4: ${TCP_TAP_HAS_READ_CONFIG_FROM}"
	#exit 0
fi
#echo "5: ${TCP_TAP_HAS_READ_CONFIG_FROM}"
#exit 0

TCP_TAP_FIRST_PORT=${TCP_TAP_FIRST_PORT-"8085"}
TCP_TAP_XTERM_DELAY=${TCP_TAP_XTERM_DELAY-"3"}
TCP_TAP_CMD=${TCP_TAP_CMD-"gdb"}
TAP_LOG_NAME=${TAP_LOG_NAME-"/tmp/${TAP_SH}.log"}
TAP_LOG=${TAP_LOG-"yes"}
TAP_SIDE_SESSION=${TAP_SIDE_SESSION-"no"}
TAP_SIDE_SESSION_EXEC=${TAP_SIDE_SESSION_EXEC-"gdb.term.sh"}
TCP_TAP_NICNAME=${TCP_TAP_NICNAME-"127.0.0.1"}

TCP_TAP_FIFO_PRE_NAME=${TCP_TAP_FIFO_PRE_NAME-"/tmp/gdbtap_"}
TCP_TAP_INUSE_AUTOINC=${TCP_TAP_INUSE_AUTOINC-"no"}

#Pipes and plumming defaults
TCP_TAP_LOG_STDIN=${TCP_TAP_LOG_STDIN-"/dev/null"}
TCP_TAP_LOG_STDOUT=${TCP_TAP_LOG_STDOUT-"/dev/null"}
TCP_TAP_LOG_STDERR=${TCP_TAP_LOG_STDERR-"/dev/null"}
TCP_TAP_LOG_PARENT=${TCP_TAP_LOG_PARENT-"/dev/null"}
TCP_TAP_LOG_CHILD=${TCP_TAP_LOG_CHILD-"/dev/null"}

# Can be used by $TAP_SIDE_SESSION_EXEC
# Measure this with the 'xwininfo' command-line utility. Note that you
# embed -display here as well.
#export XTELNET_GEOMETRY=${XTELNET_GEOMETRY-"-geometry 114x58+10+49"}

#Number of other sessions already in use (port collision avoidance)
if [ "X$TCP_TAP_INUSE_AUTOINC" == "Xyes" ]; then
	NR_INUSE=$(ps -Al | grep tcp-tap | wc -l)
else
	NR_INUSE=0
fi
TCP_TAP_PORT=$(( TCP_TAP_FIRST_PORT + NR_INUSE ))

LOCAL_IF=$TCP_TAP_NICNAME
if [ "X$TCP_TAP_NICNAME" == "X@ANY@" ]; then
	LOCAL_IF="localhost"
fi
if [ "X$TCP_TAP_NICNAME" == "X@HOSTNAME@" ]; then
	LOCAL_IF=$(hostname)
fi

if [ "$TAP_SH" == $( basename $0 ) ]; then
	#Not sourced, do something with this.

	XAPPLRESDIR=$(dirname \
		$(file $0 | \
			sed -e 's/.*symbolic link to..//' -e 's/.$//'))
	XAPPLRESDIR="${XAPPLRESDIR}/Xres"

	log_tap "START wrapper: $0 $@"
	log_tap "Environment read from:"
	log_tap "   $(echo $TCP_TAP_HAS_READ_CONFIG_FROM | sed -e 's/,/\n   /g')"
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
	log_tap "   LOCAL_IF=$LOCAL_IF"

	export TAP_LOG
	export TAP_LOG_NAME
	export TCP_TAP_EXEC="$(which ${TCP_TAP_CMD})"
	export TCP_TAP_NICNAME
	export TCP_TAP_PORT
	export TCP_TAP_FIFO_PRE_NAME
	export TCP_TAP_INUSE_AUTOINC
	export TCP_TAP_LOG_STDIN
	export TCP_TAP_LOG_STDOUT
	export TCP_TAP_LOG_STDERR
	export TCP_TAP_LOG_PARENT
	export TCP_TAP_LOG_CHILD
	export XAPPLRESDIR

	if [ "X$TAP_SIDE_SESSION" == "Xyes" ]; then
		log_tap "$TAP_SIDE_SESSION_EXEC "\
				"$LOCAL_IF "\
				"$TCP_TAP_PORT "\
				"$TCP_TAP_XTERM_DELAY &"
		$TAP_SIDE_SESSION_EXEC \
			$LOCAL_IF \
			$TCP_TAP_PORT \
			$TCP_TAP_XTERM_DELAY &
	fi

	log_tap "Exported variables:"
	log_tap "   TAP_LOG_NAME=$TAP_LOG_NAME"
	log_tap "   TAP_LOG=$TAP_LOG"
	log_tap "	TCP_TAP_EXEC=$TCP_TAP_EXEC"
	log_tap "	TCP_TAP_NICNAME=$TCP_TAP_NICNAME"
	log_tap "	TCP_TAP_PORT=$TCP_TAP_PORT"
	log_tap "	TCP_TAP_FIFO_PRE_NAME=$TCP_TAP_FIFO_PRE_NAME"
	log_tap "	TCP_TAP_INUSE_AUTOINC=$TCP_TAP_INUSE_AUTOINC"
	log_tap "	TCP_TAP_LOG_STDIN=$TCP_TAP_LOG_STDIN"
	log_tap "	TCP_TAP_LOG_STDOUT=$TCP_TAP_LOG_STDOUT"
	log_tap "	TCP_TAP_LOG_STDERR=$TCP_TAP_LOG_STDERR"
	log_tap "	TCP_TAP_LOG_PARENT=$TCP_TAP_LOG_PARENT"
	log_tap "	TCP_TAP_LOG_CHILD=$TCP_TAP_LOG_CHILD"
	log_tap "	XTELNET_GEOMETRY=$XTELNET_GEOMETRY"
	log_tap "	XAPPLRESDIR=$XAPPLRESDIR"

	log_tap "START exec: $@"
	tap "$@"
	RC=$?
	log_tap "END exec($RC): $@"
	exit $?
fi

fi
