#!/bin/sh
if ! command -v wsl.exe > /dev/null; then
	echo 'This script runs under wsl only - wsl.exe not found.'
	exit 1
fi
for d in $(wsl.exe -l -q|tr -d "\r\000" |sort -f); do

	case $d in
	jessie|stretch|docker*|podman*)
		echo ... Skipping "$d" ...
		echo
		continue
		;;
	*)

		CMD="wsl.exe -d $d --cd /etc grep ^ID= os-release"
		eval "$($CMD)"
		echo ... Updating "$d" ID="$ID" ...
		wsl.exe -d "$d" --cd /root -u root sh /home/"$USER"/.local/lib/upgrade-"${ID}".sh
		echo
		;;
	esac
done
