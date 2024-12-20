#!/bin/bash


if [[ "$UID" == 0 ]]; then
	located="/var/locatedb"
	find / -print > "$located"

	for file in "$@"; do
		grep -i "$file" "$located"
	done
else
	echo "Permission denied!"
	exit 1
fi
