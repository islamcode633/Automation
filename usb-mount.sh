#!/bin/bash


ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"

MOUNT_POINT=$(/bin/mount | /bin/grep "${DEVICE}" | /usr/bin/awk '{print $3}')


function Usage {
	echo "Использование: $0 {add|remove} device_name (например, sdb1)"
	exit 1
}


function Do_Mount {
	if [[ -n ${MOUNT_POINT} ]]; then
		echo "Предупреждение: ${DEVICE} уже смонтировано в ${MOUNT_POINT}"
		exit 1
	fi

	FS_TYPE=$(blkid "$DEVICE" | awk '{print $4}')

	MOUNT_POINT="/media/${DEVBASE}"
	echo "Точка монтирования: ${MOUNT_POINT}"
	/bin/mkdir -p "${MOUNT_POINT}"

	OPTS="rw,relatime"
	if [[ ${FS_TYPE#*=} == "vfat" ]]; then
		OPTS+=",users,gid=100,umask=000,shortname=mixed,utf8=1,flush"
	fi

	if ! /bin/mount -o "${OPTS}" "${DEVICE}" "${MOUNT_POINT}"; then
		echo "Ошибка монтирования ${DEVICE} (статус = $?)"
		exit 1
	fi

	echo "**** Устройство ${DEVICE} смонтировано в ${MOUNT_POINT} ****"
}


function Do_Unmount {
	if [[ -z ${MOUNT_POINT} ]]; then
		echo "Предупреждение: ${DEVICE} не смонтировано"
		exit 1
	else
		/bin/umount "${DEVICE}"
		echo "**** Отмонтировано ${DEVICE} ****"
		rm -rf "$MOUNT_POINT"
	fi
}


case "${ACTION}" in
	add ) Do_Mount ;;
	remove ) Do_Unmount ;;
	* ) Usage ;;
esac
