#!/bin/bash
###################################################################
#Name		:Islam
#Version	:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Edit DMI table
#Email		:gashimov.islam@bk.ru
#Program version: v1.2.4
###################################################################


[[ ! -x amidelnx_64 ]] && chmod +x amidelnx_64

while [[ $# > 1 ]]; do
	shift
done

case $1 in
	start )
		sudo ./amidelnx_64 Config.dms
		;;
	edit )
		gedit Config.dms
		;;
	* )
		echo "Unknown parameter"
		;;
esac
