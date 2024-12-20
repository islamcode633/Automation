#!/usr/bin/env bash


# Getting meta information about a file
#
# MetaData:
	# Access levels
	# Size
	# Dirname
	# Bin/shell script
	# Full Path to file


OLD_IFS="$IFS"
IFS=":"

while [[ -n "$1" ]] ; do
	cmd="$1"

	for path in $PATH; do
		if [[ -x "$path/$cmd" ]]; then
			{
				echo -e "Begin of block [ $cmd ]" ; echo ""
				file "$path"/"$cmd" ; echo "" ;
				stat "$path"/"$cmd" ; echo "" ;
				echo -ne "End of block [ $cmd ]" ; echo ""
				break
			} 2> /dev/null
		fi
	done
	shift
done

IFS="$OLD_IFS"
