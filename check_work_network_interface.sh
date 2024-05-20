#!/bin/bash
###################################################################
#Name		:Islam
#Version	:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:search for a working network interface with a specific IP address
#Email		:gashimov.islam@bk.ru
#Program version: v1.2.4
###################################################################


get_ipv4addr() {
	validate_ipv4addr $(ip a | grep -i 'global dynamic' | awk {'print $2'})
	
	validate_ipv4addr $(ip a | grep -P '[0-9]{3}'.'[0-9]{3}'.'[0-9]{3}'.'[0-9]{3}/' | awk {'print $2'})
}

validate_ipv4addr() {
	if [[ $1 = "192.168.0.1/24" || $1 = "192.168.0.2/24" ]]; then
		ping -s 1400 -c 4 0.0.0.0
		exit 0
	fi
}


get_ipv4addr
#validate_ipv4addr  "192.168.0.1/24"
