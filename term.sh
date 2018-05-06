#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2012-12-12
# Starts telnet to a specific port at a specific time
# in seconds from now

if [ -z $GDB_TERM_SH ]; then
GDB_TERM_SH="gdb.term.sh"
source gdb.tap.sh

HOST=${1-${TCP_TAP_NICNAME-"ERROR_NO_HOSTNAME_GIVEN_OR_DETECTED"} }
PORT=${2-${TCP_TAP_FIRST_PORT-"ERROR_NO_PORT_GIVEN_OR_DETECTED"} }
START_DELAY=${3-"1"}

XTELNET_GEOMETRY=${XTELNET_GEOMETRY-"600x350+0+0"}

PTS="date +%Y:%j:%T.%N"
function log_tap() {
	if [ "X$TAP_LOG" == "Xyes" ]; then
		echo -n "[$$] $($PTS) " >> $TAP_LOG_NAME
		echo "$@" >> $TAP_LOG_NAME
	fi
}

#Use screen in-between if available
SCREEN=$(which screen)
NC=$(which nc)
RLWRAP=$(which rlwrap)

log_tap "$GDB_TERM_SH: delays ${START_DELAY}"
sleep ${START_DELAY}
log_tap "$GDB_TERM_SH: starts..."

if [ "X${NC}" != "X" ] && [ "X${RLWRAP}" != "X" ]; then
	if [ "X${TERM}" == "Xxterm" ]; then
		log_tap "$GDB_TERM_SH: xterm -name gdbterm ${XTELNET_GEOMETRY} -e ${SCREEN} rlwrap nc ${HOST} ${PORT}"
		xterm -name gdbterm ${XTELNET_GEOMETRY} -e ${SCREEN} rlwrap nc ${HOST} ${PORT}
	else
		log_tap "$GDB_TERM_SH: rlwrap nc ${HOST} ${PORT}"
		rlwrap nc ${HOST} ${PORT}
	fi
else
	log_tap "$GDB_TERM_SH: xterm -name gdbterm ${XTELNET_GEOMETRY} -e ${SCREEN} telnet ${HOST} ${PORT}"
	if [ "X${TERM}" == "Xxterm" ]; then
		log_tap "$GDB_TERM_SH: xterm -name gdbterm ${XTELNET_GEOMETRY} -e ${SCREEN} telnet ${HOST} ${PORT}"
		xterm -name gdbterm ${XTELNET_GEOMETRY} -e ${SCREEN} telnet ${HOST} ${PORT}
	else
		log_tap "$GDB_TERM_SH: telnet ${HOST} ${PORT}"
		telnet ${HOST} ${PORT}
	fi
fi
log_tap "$GDB_TERM_SH: exits..."

fi
