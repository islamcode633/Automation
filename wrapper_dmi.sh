#!/bin/bash


function usage {
	echo "Example Use:"
	echo "wrapper_dmi [ bios ] [ system ] [ baseboard ]"
	echo "wrapper_dmi [ chassis] [ processor ] [ memory ]"
	echo "wrapper_dmi [ cache ] [ connector ] [ slot ]"
	echo ""
}


function wrapper_dmi {
	dmi="dmidecode"
	option="-t"

	case "$1" in
		"--help" | "-h" | "help" | "--h" ) usage && exit 1 ;;
		"bios" )
			echo "# --- Begin Block BIOS:" ; echo ""
			$dmi "$option" 0 "$option" 13
			;;
		"system" )
			echo "# --- Begin Block System:" ; echo ""
			$dmi "$option" 1 "$option" 12 "$option" 15 "$option" 23 "$option" 32
			;;
		"baseboard" )
			echo "# --- Begin Block Baseboard:" ; echo ""
			$dmi "$option" 2 "$option" 10 "$option" 41
			;;
		"chassis" )
			echo "# --- Begin Block Chassis:" ; echo ""
			$dmi "$option" 3
			;;
		"processor" ) 
			echo "# --- Begin Block Processor:" ; echo ""
			$dmi "$option" 4 
			;;
		"memory" )
			echo "# --- Begin Block Memory:" ; echo ""
			$dmi "$option" 5 "$option" 6 "$option" 16 "$option" 17
			;;
		"cache" ) 
			echo "# --- Begin Block Cache:" ; echo ""
			$dmi "$option" 7
			;;
		"connector" ) 
			echo "# --- Begin Block Connector:" ; echo ""
			$dmi "$option" 8 
			;;
		"slot" )
			echo "# --- Begin Block Slot:" ; echo ""
			$dmi "$option" 9 
			;;
		"default" ) ${dmi% -t} ;;
		* ) echo "Valid parameter not found!" && exit 1 ;;
	esac
	unset -v "dmi" "option"
}


while [[ -n "$1" ]]; do
	wrapper_dmi "$1"
	shift
done
