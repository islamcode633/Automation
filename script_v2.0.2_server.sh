#!/bin/bash -
###################################################################
#Name			:Islam
#Version		:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Installing and updating utilities, Collecting system information, Load tests
#Email			:gashimov.islam@bk.ru
#Program version: v2.0.2
###################################################################



INFORMATION_SECTOR_SEPARATOR="###################################################################"
LOG_FILE=hwinfo_$(date '+%F').log
APT_SOURCE_LIST="/etc/apt/sources.list"


[[ -f $LOG_FILE ]] && rm -f $LOG_FILE


function Update_Repository {
	echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy main restricted > $APT_SOURCE_LIST && {
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates main restricted ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy universe
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates universe ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse ; echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates multiverse
		echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse ; echo deb http://security.ubuntu.com/ubuntu jammy-security main restricted
		echo deb http://security.ubuntu.com/ubuntu jammy-security universe ; echo deb http://security.ubuntu.com/ubuntu jammy-security multiverse
	} >> $APT_SOURCE_LIST
	apt update
}


function Install_Utils {
	##	The function updates the repositories and installs the necessary utilities
	## 	Additional hddtemp/Phoronix test suite installation
	##
	##	Global var: APT_SOURCE_LIST		Options: "$@" - utils
	##	Local var: No					Return object: No


	apt install $@ -y
	[[ ! -f hddtemp_0.3-beta15-53_amd64.deb ]] && { 
		wget http://archive.ubuntu.com/ubuntu/pool/universe/h/hddtemp/hddtemp_0.3-beta15-53_amd64.deb
		apt install ./hddtemp_0.3-beta15-53_amd64.deb
	}

	[[ ! -d phoronix-test-suite ]] && {
		git clone https://github.com/phoronix-test-suite/phoronix-test-suite
		sh ~/phoronix-test-suite/install-sh
	}
} 2>/dev/null


function Checking_Installed_Packages {
	##	The function checks whether all necessary packages have been installed 
	##	in the required directories
	##
	##	Global var: No												Options: "$@" - downloaded packages
	##	Local var: count_packages, package,							Return object: No
	##	########## name_installed_package, path_to_binary_file

	
	local -i count_packages=0
	for package; do
		name_installed_package="$(dpkg -l | grep $package | awk {'print $2'})" ; path_to_binary_file="$(whereis $package | awk {'print $2'})"
		[[ "$name_installed_package" == "$package" || "$path_to_binary_file" == "/usr/bin/$package" || "$path_to_binary_file" == "/usr/sbin/$package" ]] && {
			count_packages=$(( $count_packages + 1 ))
			echo "Package installed: $package" ; continue
		}
		echo "Package not installed: $package"
	done
	echo "[SUM] of $# packages installed $count_packages" ; echo ""

	unset -v "package" "count_packages" "name_installed_package" "path_to_binary_file"
}


function System_Info {
	##	The function collects data about the hardware and system
	##
	##	Global var: INFORMATION_SECTOR_SEPARATOR, LOG_FILE				Options: "$@" - utilities for collecting data about the system and hardware	
	##	Local var: cmd, search_disks=name disk/partition				Return object: No


	call_disk_subsystem=$1
	[[ "$call_disk_subsystem" == "disk_subsystem" ]] && {
		shift
		for cmd; do
			for search_disks in "$(df -h | cut -d' ' -f1 | grep -iE '/dev/nvme*|/dev/sd?')"; do
				$cmd $search_disks ; $INFORMATION_SECTOR_SEPARATOR
			done
		done
	return
	}

	for cmd; do
		$cmd
		echo "$INFORMATION_SECTOR_SEPARATOR"
	done

	unset -v "cmd" "search_disks"
} >> $LOG_FILE 2>/dev/null


function Stress_Test {
	##	The function conducts load tests of all system components
	##	CPU/Memory/Disk/Bus/Network/IO
	##
	##	Global var: No													Options: No
	##	Local var:	size_ram=All RAM, half_usage_ram=50% of RAM,		Return object: No
	##	##########	load=thread/system calls, time=sec


	local -i size_ram ; local -i half_usage_ram
	local -i load=100 ; local -i time=180

	for ((i=0; i<4; i++)); do 7z b -mm=*; done
	stress-ng -c 0 -m 0 -d 0 -i 0 -f $load -u $load --pci $load --memcpy $load --mcontend $load --matrix $load --malloc $load --kvm $load --hash $load -C 0 -B 0 -t 20m --tz --metrics-brief
	ping -c 15 ya.ru

	size_ram=$(sudo hwinfo --memory | grep -i "memory size" | awk {'print $3'})
	half_usage_ram=$(( $size_ram * 50  / 100 * 1000 / 2 ))
	mbw -n 10 $half_usage_ram

	sysbench cpu --threads=100 --time=$time run
	sysbench memory --memory-block-size=16384 --time=$time run
	sysbench fileio --file-num=512 --file-block-size=65536 --file-test-mode=seqwr --time=$time run
	find . -maxdepth 1 -iname "test_file.*" -or -iname "tmp-stress-ng*" | xargs rm -rf

	unset -v "size_ram" "half_usage_ram" "load" "time"
} >> result_stress_test.txt


function main {
	printf -v start '%(%d-%m-%Y %H:%M:%S)T' '-1'
	Update_Repository
	Install_Utils "lshw" "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi" "hwinfo" "hw-probe" "cpufrequtils"
	Install_Utils "curl" "git" "sqlite3" "bzip2" "php-cli" "php-xml" "hdparm" "smartmontools"
	Install_Utils "sysbench" "mbw"
	echo -ne "\nUpdate repository and install utils	--------------------------------------------------	[ OK ] \n"
	Checking_Installed_Packages "lshw"  "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi"  "hwinfo" "hw-probe" "cpufrequtils" "sysbench"
	Checking_Installed_Packages "hdparm" "smartmontools" "curl" "git" "sqlite3" "bzip2" "php-cli" "php-xml" "mbw"
	echo -ne "Checking installed packages		--------------------------------------------------	[ OK ] \n"

	System_Info "lscpu" "cpufreq-info" "inxi -F" "ip a"  "lshw" "hwinfo --cpu --usb --memory --pci --disk --network --scsi" \
				"phoronix-test-suite system-info" "phoronix-test-suite system-sensors" "sensors"
	System_Info "fdisk -lx" "lspci -vvv" "lsscsi -LCv" "lsblk" "lsusb" "df -h" "free -h" "dmidecode"
	System_Info "disk_subsystem" "smartctl -a " "hdparm -IH " "hddtemp"
	echo -ne "Сollection of system information	--------------------------------------------------	[ OK ] \n" 
	echo -ne "Done! Look at the Log File! \n"
	
	#logs "sosreport" "hw-probe -all -save ~" "dmesg"
	Stress_Test
	printf -v end '%(%H:%M:%S)T' '-1'
	echo $start $end ; unset -v "start" "end"
}

main
