# UI part of gdb.remote.sh
# This is not even a script, stupid and can't exist alone. It is purely
# meant for being included.


function print_remote_help() {
	clear
			cat <<EOF
Usage: $REMOTES_SH_INFO [options]

Connects to a tapped (tcp_tap) remote GDB session

Works on std-in/out

Options. Defautls within []:
  -h              This help

Example:
  $REMOTES_SH_INFO

EOF
}
	while getopts h OPTION; do
		case $OPTION in
		h)
			print_remote_help $0
			exit 0
			;;
		?)
			echo "Syntax error:" 1>&2
			print_remote_help $0 1>&2
			exit 2
			;;

		esac
	done
	shift $(($OPTIND - 1))

