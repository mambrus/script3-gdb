# UI part of gdb.connect.sh
# This is not even a script, stupid and can't exist alone. It is purely
# meant for being included.

function print_connect_help() {
	clear
			cat <<EOF
Usage: $CONNECT_SH_INFO [options]

Connects to a tapped (tcp_tap) GDB session. It does a fair guess where to
connect by re-using configurations. Options should only be necessary if
asumptions are wrong.

To disconnect: press ^C.

$CONNECT_SH_INFO requires the programs "screen", "nc", "rlwrap" to be
installed. This system has the following installed:

SCREEN=$(which screen)
NC=$(which nc)
RLWRAP=$(which rlwrap)

Options. Defautls within []:
  -h              This help
  -p              port [${TCP_TAP_PORT}]
  -H              host [$LOCAL_IF]

Example:
  $CONNECT_SH_INFO

EOF
}
	while getopts hp:H: OPTION; do
		case $OPTION in
		h)
			print_connect_help $0
			exit 0
			;;
		H)
			CON_HOST=$OPTARG
			;;
		p)
			CON_PORT=$OPTARG
			;;
		?)
			echo "Syntax error:" 1>&2
			print_connect_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

	SCREEN=$(which screen)
	NC=$(which nc)
	RLWRAP=$(which rlwrap)


if	[ "X${NC}" == "X" ] || \
	[ "X${RLWRAP}" == "X" ] || \
	[ "X${SCREEN}" == "X" ] 
then
	print_connect_help
	echo "ERROR: missing requirements" 1>&2
	exit 1
fi
	CON_HOST=${CON_HOST-${LOCAL_IF}}
	CON_PORT=${CON_PORT-${TCP_TAP_PORT}}

