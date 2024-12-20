#!/bin/bash


function Manual {
	echo " This script will decompress and unarchive files with suffix .tar .gz .bz2 .zip"
	echo ""
	cat <<-EoH 
		 Pass parameter script arg1 [ arg2 ... ], where [ OPTIONAL ]
		 At least one argument is required
		 Example:
		  script name1.tar name2.tar.gz name3.tar.bz name4.tar.zip
		  script name.tar
		  script name.tar.gz
		  script name.gz name2.bz2
		  And etc...
	EoH
}


function Dispatcher {
	local compressed="$1"
	Validate "$compressed" || exit 1

	case "$compressed" in
		*.gz )
			# get file *.tar
			gunzip "$compressed" && Unarchive "${compressed%.gz}"
			echo "Done !"
			;;
		*.bz2 )
			# get file *.tar
			bunzip2 "$compressed" && Unarchive "${compressed%.bz2}"
			echo "Done !"
			;;
		*.zip )
			unzip "$compressed" && Unarchive "${compressed%.zip}"
			echo "Done !"
			;;
		*.tar )
			Unarchive "$compressed"
			echo "Done !"
			;;
		* ) echo "Is not compressed file or archive ---> \"$compressed\" !" ;;
	esac
}


function Validate {
	local file="$1"
	if [[ ! -f "$file" ]]; then 
		echo "Not found file ---> $file!"
		return 1
	fi
}


function Unarchive {
	local archive="$1"
	[[ "${archive##*.}" == "tar" ]] && tar -xvf "$archive"
}


function Entry {
case "$1" in
	"help" | "--help" | "-h" | "--h" ) Manual ;;
	* )
		for el in "$@"; do
			Dispatcher "$el"
		done
		;;
esac
}

Entry "$@"
