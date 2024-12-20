#!/bin/bash
###################################################################
#Name			 :Islam
#Version		 :Linux  6.8.0-47-generic Ubunta 22.04.1 LTS
#Arhitecture     :x86_64
#Description	 :Changing the processor frequency
#Email			 :gashimov.islam@bk.ru
#Program version : 1.0
###################################################################


# add fmt printf
# add usage doc
# add check edit


### --- Init of vars during startup
CPU_MAX_MHZ=""
CPU_MIN_MHZ=""
###
MIN_FREQ=""
MAX_FREQ=""
FLAG=""
### ---

CPU_FREQ_MHZ=$(lscpu | grep -iE "max|min" | sed 's/,//g;s/ //g' | cut -d ':' -f 2)
COUNT_CORES="$(sed 's/-/ /g' /sys/devices/system/cpu/online)"


ERROR_PARAMETER="Parameter is not number!"
ERROR_FLAG="Expected flag not found!"



function Usage {
    cat <<-EoH
        The script must be run as root. Use sudo or su -

        To increase processor frequencies use the following syntax:
        -
        - sudo change_freq_processor.sh max-freq N min-freq N
        -
         Where N is the desired core frequency in KHz. N is integer.
         max-freq is maximum frequencty, min-freq is minimum frequency.
         The max and min frequency arguments are specified in any order.
        -
        - sudo change_freq_processor.sh max-freq 4800000 min-freq 800000
        -
        After rebooting the system the set frequencies will be reset
        to the original ones.

         ---WARNING!---
         The maximum and minimum processor frequency values cannot
         exceed the frequency specified in the CPU manufacturer's
         specification or hardware limitation.
         ---       ---
	EoH
}


function Check_Success_Write_ToFile {
    :
}


function Get_MAX_Freq {
    CPU_MAX_MHZ=$(echo ${CPU_FREQ_MHZ} | cut -d ' ' -f1)
    CPU_MAX_MHZ=${CPU_MAX_MHZ%0*}
}


function Get_MIN_Freq {
    CPU_MIN_MHZ=$(echo ${CPU_FREQ_MHZ} | cut -d ' ' -f2)
    CPU_MIN_MHZ=${CPU_MIN_MHZ%0*}
}


function Scaling_Min_Freq {
    local min_freq ; min_freq="$1"

    for i in $(seq $COUNT_CORES); do
        echo "$min_freq" | tee "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq"
    done
}


function Scaling_Max_Freq {
    local max_freq ; max_freq="$1"

    for i in $(seq $COUNT_CORES); do
        echo "$max_freq" | tee "/sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
    done
}


function Validate_Param {
    frequency="$1"
    if [[ "$frequency" =~ ^[0-9]+$  ]] && ((CPU_MIN_MHZ <= frequency && frequency <= CPU_MAX_MHZ)); then
        return 0
    else
        printf "%s " "$ERROR_PARAMETER"
        exit 1
    fi
}


function Parse_Args {
    Get_MAX_Freq
    Get_MIN_Freq

    while (( $# != 0 )); do
        FLAG="$1"
        case "$FLAG" in
            "-h" | "--h" | "--help" | "help" )
                Usage
                ;;
            "min-freq" )
                shift
                declare -r MIN_FREQ="$1"
                Validate_Param "$MIN_FREQ" && {
                    # Before MD5SUM
                    #Check_Edit_InScaling_Min_Freq
                    Scaling_Min_Freq "$MIN_FREQ"

                    # After MD5SUM
                    #Check_Edit_InScaling_Min_Freq
                }
                ;;
            "max-freq" )
                shift
                declare -r MAX_FREQ="$1"
                Validate_Param "$MAX_FREQ" && {
                    #Check_Edit_InScaling_Max_Freq
                    Scaling_Max_Freq "$MAX_FREQ"
                    #Check_Edit_InScaling_Max_Freq
                }
                ;;
            * ) printf "%s " "$ERROR_FLAG" ;;
        esac
        shift
    done
}

Parse_Args "$@"
