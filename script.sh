#!/bin/bash
###################################################################
#Name		:Islam
#Version	:Linux 6.5.0-25-generic Ubunta 22.04 LTS
#Description	:Installing and updating utilities, Collecting system information, Load tests
#Email		:gashimov.islam@bk.ru
#Program version: v1.2.4
###################################################################


LOG_FILE=hwinfo_$(date '+%F').log
[[ -f $LOG_FILE ]] && rm $LOG_FILE

while [ -n "$1" ]; do
	shift
done

edit_apt_repository() {
    srvlist=/etc/apt/sources.list

    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy main restricted > $srvlist
    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates main restricted >> $srvlist
    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy universe >> $srvlist
    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates universe >> $srvlist
    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy multiverse >> $srvlist
    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-updates multiverse >> $srvlist
    echo deb http://ru.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse >> $srvlist
    echo deb http://security.ubuntu.com/ubuntu jammy-security main restricted >> $srvlist
    echo deb http://security.ubuntu.com/ubuntu jammy-security universe >> $srvlist
    echo deb http://security.ubuntu.com/ubuntu jammy-security multiverse >> $srvlist
}

install_packages() {
	apt update	
	apt install lshw inxi stress-ng p7zip-full p7zip-rar lsscsi hwinfo hw-probe -y
	echo ""
}

checking_installed_package() {
	for package; do
		[[ $(dpkg -l | grep $package | awk {'print $2'}) == $package ]] && echo "Package installed: $package" && continue
		
		echo "Package not installed: $package"
	done
	unset -v "package"

	echo ""
}

search_bin_file() {
	count_package=0
	for binary_file; do
		[[ $(ls /usr/bin/* | grep $binary_file) || $(ls /usr/sbin/* | grep $binary_file) ]] && echo "Binary file: $binary_file ------> [ OK ]"
		count_package=$(( $count_package + 1 )) && continue
		
		echo "Binary file missing: $binary_file  ------> [ FAIL ]"
	done
	unset -v "binary_file"
 
	echo -ne "\n[SUM] of $# packages installed $count_package\n"
}

system_info() {
	for comm; do
		$comm >> $LOG_FILE
		echo >> $LOG_FILE
	done
	unset -v "comm"
	 
	echo -ne "Done! Look at the Log File! \n"
}

p7zip() {
	for iter; do
		echo "Saving the report to a file ------> $iter"
		7z b -mm=* > $iter.txt 
	done
	unset -v "iter"
}

stress_ng() {
	echo "Start stress_ng"
	script -c 'stress-ng -c 0 -m 0 -d 0 -i 0 -C 0 -B 0 -t 1m --tz --metrics-brief' > stressng.txt
	rm -f typescript
}

output_dmi_tabble() {
	cat $LOG_FILE | grep -E 'BIOS Information|System Information|Base Board Information|Chassis Information' -A 6
}

main() {
	printf -v start '%(%d-%m-%Y %H:%M:%S)T' '-1'
	edit_apt_repository
	install_packages
	checking_installed_package "lshw"  "inxi" "stress-ng" "p7zip-full" "p7zip-rar" "lsscsi"  "hwinfo" "hw-probe"
	search_bin_file "lshw" "inxi" "stress-ng" "7z" "lsscsi" "hwinfo" "hw-probe"	
	system_info "lscpu" "lsusb" "lspci" "lsscsi" "lsblk" "inxi -F" "free -h" "df -h" "lshw" \
				   "dmidecode" "hwinfo --cpu --usb --memory --pci --disk --network --scsi"

	#stress_ng
	#p7zip "7z_one_result" "7z_two_result" "7z_three_result" "7z_four_result"
	#[[ -f $LOG_FILE ]] && output_dmi_tabble
	printf -v end '%(%H:%M:%S)T' '-1'
	echo $start $end
}

main
