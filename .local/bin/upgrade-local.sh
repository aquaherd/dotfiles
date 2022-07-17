#!/bin/sh

managers="apk apt dnf kiss pacman swupd xbps-install yum"

. ~/.local/lib/chroot.sh

action_get() 
{
    case $1 in
    apk)			echo 'apk upgrade -a' ;;
    apt) 			echo 'apt-get update && apt-get dist-upgrade -y && apt-get autoremove --purge -y && apt-get autoclean' ;;
    dnf) 			echo 'dnf upgrade && dnf autoremove' ;;
    kiss) 			echo 'KISS_PROMPT=0 kiss u && KISS_PROMPT=0 kiss u' ;;
    pacman) 		echo 'pacman -Syu --noconfirm && pacman -Sc --noconfirm' ;;
    swupd) 			echo 'swupd update' ;;
    xbps-install) 	echo 'xbps-install -Syu && xbps-remove -oy' ;;
    yum) 			echo "yum upgrade" ;;
    *) 				return 1 ;;
    esac
}

chroot_upgrade() 
{
	local u
	local a
	local c
	
    echo "Checking $1 $2"
    if mount | grep -q $1; then
		echo will not fsck $1
	else
		sudo fsck -y $1
    fi
	
	chroot_mount $1 $2
    
    if [ -f /run/mount/$2/etc/os-release ]; then
		. /run/mount/$2/etc/os-release
		echo "Found $PRETTY_NAME"
		
        for u in $managers; do
            a=$(sudo chroot /run/mount/$2 which $u 2>/dev/null) || continue

            echo --- $u ---
            if c=$(action_get $u); then
                echo Action: $c
                sudo chroot /run/mount/$2 sh -lc "$c"
            fi
            break
        done
        
        MTP=/run/mount/$2 build-uefi.sh
    else
		echo "Skipped non-linux"
    fi
    
    chroot_umount $1 $2
}

local_upgrade() 
{
	local u
	local a
	local c
	for u in $managers; do
		a=$(which $u 2>/dev/null) || continue

		echo --- $u ---
		if c=$(action_get $u); then
			echo Action: $c
			sudo sh -lc "$c"
		fi
		break
	done
	
	build-uefi.sh
}

chroot_upgrade_one() 
{
	local t
	local n
	local d
    if [ -e $1 ]; then
        t=$(sudo lsblk -lno FSTYPE $1)
        n=$(basename $1)
        d=$(readlink -f $1)
        # skip local
        if mount | grep -q "$d on / type"; then
            local_upgrade
            return 0
        fi

        case $t in
        ext*)
            chroot_upgrade $d $n || return 1
            ;;
        *)
			echo "$n: type $t unhandled $d"
			return 1
            ;;
        vfat|swap)
			echo "Skip $n: type $t at $d"
			;;
        esac
    fi

    return 0
}

chroot_upgrade_all() 
{
    for f in /dev/disk/by-label/*; do
		echo "*** $(basename $f) begin ***"
        chroot_upgrade_one $f || echo FAIL
		echo "*** $(basename $f) end ***"
		echo
    done
}

usage() 
{
    echo "Usage: $(basename $0) all | [partition]"
}

chroot_upgrade_args() 
{
    while [ $# -gt 0 ]; do
		echo "*** $(basename $1) begin ***"
        chroot_upgrade_one /dev/disk/by-label/$1 || echo FAIL
		echo "*** $(basename $1) end ***"
        shift 
    done
}

case $1 in
    "") usage ;;
    all) chroot_upgrade_all ;;
    *) chroot_upgrade_args $* ;;
esac
