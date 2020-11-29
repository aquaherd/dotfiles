#!/bin/sh

. ~/.local/lib/chroot.sh

shells="/bin/bash /bin/ash /bin/sh"

usage()
{
	echo "Usage: $(basename $0) list | [parition]"
}

enter()
{
	if [ ! -e $1 ]; then
		exit 2
	fi
	local n=$(basename $1)
	local d=$(readlink -f $1)
	
	chroot_mount $d $n
	
	for s in $shells; do
		if [ -f /run/mount/$n/$s ]; then
			sudo chroot /run/mount/$n $s -l
			break
		fi
	done
	
	chroot_umount $d $n
}

case $1 in
    "") usage ;;
    list) list ;;
    *) enter /dev/disk/by-label/$1 ;;
esac
