#!/bin/bash
###################################################################
#Name		:Islam
#Version	:Linux 6.5.0-26-generic Ubunta 22.04 LTS
#Description	:Search for the name of the USB device in the system
#Email		:gashimov.islam@bk.ru
###################################################################


USERPATH=/home/$(whoami)

searchlogicalpartition=$(sudo dmesg | tail | grep -P '[a-z]{3}:'\ '[a-z]{3}[1-9]' | awk {'print $3'})
searchpathmount=$(sudo mount | grep $searchlogicalpartition | awk {'print $3'})
[[ $(cp -r $searchpathmount/acceptancetesting $USERPATH) ]] && cd $USERPATH/acceptancetesting
[[ $(sudo bash script.sh) ]]
