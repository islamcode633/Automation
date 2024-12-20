#!/bin/bash -
###################################################################
#Name			:Islam
#Version		:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Installing and updating utilities, Collecting system information, Load tests
#Email			:gashimov.islam@bk.ru
#Program version: v2.2.0
###################################################################


# add trap namefunction() -> release resources after the script has been completed [ + ]
# add { repo } > sources.list [ + ]
# add half_usage_ram=$(($(( $(( $size_ram * 50 )) / 100 )) * 1000 )) -> $((exp)) [ + ]
# add "$@" [ + ]
# add delete  lssci  [ + ]
# add pts/install-sh [ + ] 
# add "$(exp)" [ + ]


# rewrite funcion System_info [ Inprocess ]
# add save results -> dirnameMACEth
# add put sysinfo to files cpuinfo.txt memory.txt dmidecode.txt pci_bus.txt usb.txt disks.txt eth.txt


# add flags
# add check count transfer parametrs in script
# add function flags matching and valid data

# add test performance scritp use /usr/bin/time(external) or time(internal)
# add update only repo the required packages
# add menu
# add function send some mail *.log
# add function convert to *.html
# add function fmt() -> output data to term **
# add transfer argm for disk-sybsystem
# add code exit N


# wait
# use linker for bash
# use bash unit -> BATS/shunits
# after testing delete main fucntion


# enabling bash strict mode
#set -vxo pipefail


APT_SOURCE_LIST=/etc/apt/sources.list
INSTALLATION_PATH=/home/ubuntu/phoronix-test-suite/install-sh
REPORT=/home/terminator/Reports
SCRIPT_VERSION="$0 - v2.2.0"


if [[ ! -d "$REPORT" ]]; then
	mkdir -p $REPORT
else
	rm -rf $REPORT/*
fi


function Interrupt_Execution {
	echo " Script terminated !"
	exit 1
}


function Data_Formatting {
	:
}


function Display_Help {
		##	This function displays information about script launch modes
		##
		##	Global var: No		Options: No
		##	Local var: No		Return object: No


	cat <<-EoH
	Options:
    	Usage syntax: script.sh [ OPTION [ ARG ]] arguments in square brackets [ ...[ ... ]] optional 
        -t | --time  Execution time of stress-ng
        -v | --version  Displaying information about the script version
        -h | --help  Displays information about script launch modes
        -l | --load  Selecting the load on the system. If the flag is not set to a value, tests will be run with minimal load
                     The recommended range is 100–1000, with 100 being the minimum value
                     WARNING! High loads can lead to freezes, reboots, overheating and system failures
        -i | --iter  Number of repetitions of the 7z stress test. The approximate execution time for one iteration is 5 minutes
	Example:
        script.sh -t[ --time ] N -v[ --version ] -h[ --help ] -l[ --load ] N -i[ --iter ] N
        script.sh -t 8 -l 100 -i 2
        script.sh --time 24 --load 500 --iter 2
        script.sh -t 24 -l 800 --iter 10
        Used separately from other flags script.sh -h[ --help ] or -v[ --version ]
		EoH
	exit 1
}


function Update_Repository {
		##	The function overwrites source.list and indexes packages
		##
		##	Global var: APT_SOURCE_LIST		Options: No
		##	Local var: No					Return object: No


	{
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy main restricted
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates main restricted ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy universe
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates universe ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates multiverse
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse ; echo deb http://security.ubuntu.com/ubuntu jammy-security main restricted
		echo deb http://security.ubuntu.com/ubuntu jammy-security universe ; echo deb http://security.ubuntu.com/ubuntu jammy-security multiverse ;
	} > "$APT_SOURCE_LIST" && apt update
} 2>/dev/null


function Install_Utils {
	##	The function installs the necessary utilities
	## 	Additional hddtemp/Phoronix test suite installation
	##
	##	Global var: INSTALLATION_PATH				Options: "$@" - utils
	##	Local var: No								Return object: No


	apt install "$@" -y

		[[ ! -f hddtemp_0.3-beta15-53_amd64.deb ]] && { 
		wget http://archive.ubuntu.com/ubuntu/pool/universe/h/hddtemp/hddtemp_0.3-beta15-53_amd64.deb
		apt install ./hddtemp_0.3-beta15-53_amd64.deb && echo -ne "hddtemp		--------------------------------------------------	[ OK ] \n"
	}

	[[ ! -d phoronix-test-suite ]] && {
		git clone https://github.com/phoronix-test-suite/phoronix-test-suite
		bash  "$INSTALLATION_PATH" && echo -ne "phoronix-test-suite		--------------------------------------------------	[ OK ] \n"
	}
}


function Checking_Installed_Packages {
	##	The function checks whether all necessary packages have been installed 
	##	in the required directories
	##
	##	Global var: No																		Options: "$@" - downloaded packages
	##	Local var: count_packages, package, name_installed_package, path_to_binary_file		Return object: No


	local -i count_packages=0
	for package in "$@"; do
		name_installed_package="$(grep -i "$package" <(dpkg -l) | cut -d' ' -f3)"
		path_to_binary_file="$(command -v "$package")"
		[[ -n "$name_installed_package" || -n "$path_to_binary_file" ]] && {
			((count_packages += 1))
			echo "Package installed: $package"
			continue
		}
		echo "Package not installed: $package"
	done
	echo "[SUM] of $# packages installed $count_packages" ; echo ""

	unset -v "package" "count_packages" "name_installed_package" "path_to_binary_file"
}


function System_Info {
	for cmd_with_flags in "$@"; do
		for cmd in $cmd_with_flags; do
			case $cmd in
				"lscpu" | "cpufreq-info" ) 
					$cmd_with_flags >> cpuinfo.txt 
					break	
					;;
				"dmidecode" ) 
					$cmd_with_flags >> dmidecode.txt 
					break
					;;
				"fdisk" | "hddtemp" | "smartctl" | "hdparm" ) 
					$cmd_with_flags /dev/sd[a-d] >> disks.txt 
					break
					;;
				"lsblk" | "lsusb" ) 
					$cmd_with_flags >> usb.txt 
					break
					;;
				"lspci" ) 
					$cmd_with_flags >> pci_bus.txt 
					break
					;; 
				"hwinfo" | "lshw" | "free" ) 
					$cmd_with_flags >> memory.txt 
					break
					;;
				"ip" ) 
					$cmd_with_flags >> eth.txt 
					break
					;;
				* )
					$cmd_with_flags >> general_info_about_sys_and_sensors.txt
					break
					;;
				esac
		done 2>/dev/null
	done

	mv *.txt $REPORT
	unset "cmd_with_flags" "cmd"
}


function Stress_Test {
	##	The function conducts load tests of all system components
	##	CPU/Memory/Disk/Bus/Network/IO
	##
	##	Global var: No													Options: No
	##	Local var:	size_ram=All RAM, half_usage_ram=50% of RAM,		Return object: No
	##	##########	load=thread/system calls, time=sec


	local -i size_ram ; local -i half_usage_ram
	local -i load=100 ; local -i time=90

	for ((i=0; i<1; i++)); do 7z b -mm=*; done
	stress-ng -c 0 -m 0 -d 0 -i 0 -f $load -u $load --pci $load --memcpy $load --mcontend $load --matrix $load --malloc $load --kvm $load --hash $load -C 0 -B 0 -t $time --tz --metrics-brief
	ping -c 15 ya.ru

	size_ram=$(sudo hwinfo --memory | grep -i "memory size" | awk {'print $3'})
	((half_usage_ram = size_ram * 50  / 100 * 1000 / 2 ))
	mbw -n 10 "$half_usage_ram"

	sysbench cpu --threads=100 --time=$time run
	sysbench memory --memory-block-size=16384 --time=$time run
	sysbench fileio --file-num=512 --file-block-size=65536 --file-test-mode=seqwr --time=$time run
	find . -maxdepth 1 -iname "test_file.*" -or -iname "tmp-stress-ng*" | xargs rm -rf

	unset -v "size_ram" "half_usage_ram" "load" "time"
}


function main {
	printf -v start '%(%d-%m-%Y %H:%M:%S)T' '-1'

	while getopts ':-:vht:l:i:' OPTION ; do
		case "$OPTION" in
			v )
				echo "$SCRIPT_VERSION"
				exit 1
				;;
			h )
				Display_Help
				exit 1
				;;
			t ) TIME="${OPTARG#*=}" ; echo $TIME ;;
			l ) LOAD="${OPTARG#*=}" ; echo $LOAD ;;
			i ) ITERATION="${OPTARG#*=}" ; echo $ITERATION ;;
			- )
				case "$OPTARG" in
					version )
							echo "$SCRIPT_VERSION"
							exit 1
							;;
					help )
							Display_Help
							exit 1
							;;
					time=* ) TIME="${OPTARG#time=}" ; echo $TIME ;;
					load=* ) LOAD="${OPTARG#load=}" ; echo $LOAD ;;
					iter=* ) ITERATION="${OPTARG#iter=}" ; echo $ITERATION ;;
					* )
						echo "Error: unknow long argument: $OPTARG"
						exit -1	
				esac
			#: )
			#	echo "Error: no arg supplied to -$OPTARG"
			#	exit -1
			#	;;
			#? )
			#	echo "Start stress-ng..."
			#	Stress_Test
			#	exit 0
			#	;;
		esac
	done

	### --- Abort work script --- ###
	trap Interrupt_Execution SIGINT

	### --- Help about interfaces --- ###
	#Display_Help
	### function: Off

	### --- Formatting data in stdout --- ###
	#Data_Formatting
	### function: Off

	### --- Update repo for apt --- ###
	Update_Repository
	
	### --- Install packages --- ###
	Install_Utils "lshw" "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi" "hwinfo" "hw-probe" "cpufrequtils"
	Install_Utils "curl" "git" "sqlite3" "bzip2" "php-cli" "php-xml" "hdparm" "smartmontools"
	Install_Utils "sysbench" "mbw"
	
	### --- Check installed packages --- ###
	echo -ne "\nUpdate repository and install utils	--------------------------------------------------	[ OK ] \n"
	Checking_Installed_Packages "lshw"  "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi"  "hwinfo" "hw-probe" "cpufrequtils" "sysbench"
	Checking_Installed_Packages "hdparm" "smartmontools" "curl" "git" "sqlite3" "bzip2" "php-cli" "php-xml" "mbw" "hddtemp" "phoronix-test-suite"
	echo -ne "Checking installed packages		--------------------------------------------------	[ OK ] \n"
	
	### --- Getting  about system info --- ###
	System_Info "lscpu" "cpufreq-info" "dmidecode" "fdisk -lx" "hddtemp" "smartctl -a" "hdparm -IH"
	System_Info "lsblk" "lsusb -vv" "lspci -vvv" "hwinfo --memory" "lshw -C memory" "free -h" "ip a"
	System_Info "inxi -F" "phoronix-test-suite system-info" "phoronix-test-suite system-sensors" "sensors"
	echo -ne "Сollection of system information	--------------------------------------------------	[ OK ] \n" 
	echo -ne "Done! Look at the Files in dir -------> Reports \n"
	
	### --- Load test --- ###
	Stress_Test

	printf -v end '%(%H:%M:%S)T' '-1' ; echo $start $end
	unset -v "start" "end"
}

main
