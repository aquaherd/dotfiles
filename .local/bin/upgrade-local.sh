#!/bin/sh

managers="apk apt dnf kiss pacman swupd xbps-install yum"
basename=$(basename "$0")

for sudo in doas sudo; do
	if command -v $sudo > /dev/null; then
		break
	fi
done
export sudo
# shellcheck source=/home/hakan/.local/lib/chroot.sh
. ~/.local/lib/chroot.sh

check_esp()
{
	if [ -d /sys/firmware/efi ] &&
		! findmnt -rn -M /boot/efi -t vfat -O rw >/dev/null; then
		echo "Upgrade refused: /boot/efi must be mounted read-write as vfat." >&2
		return 1
	fi
}

action_get() 
{
	case $1 in
		apk)		echo 'apk upgrade -a' ;;
		apt) 		echo 'apt-get update && apt-get dist-upgrade -y && apt-get autoremove --purge -y && apt-get autoclean' ;;
		dnf) 		echo 'dnf upgrade && dnf autoremove' ;;
		kiss) 		echo 'KISS_PROMPT=0 kiss u && KISS_PROMPT=0 kiss u' ;;
		pacman) 	echo 'pacman -Syu --noconfirm && pacman -Sc --noconfirm' ;;
		swupd) 		echo 'swupd update' ;;
		xbps-install)	echo 'xbps-install -Syu && xbps-remove -oy' ;;
		yum) 		echo "yum upgrade" ;;
		*) 		return 1 ;;
	esac
}

chroot_upgrade() 
{
	u=""
	c=""
	echo "Checking $1 $2"
	if mount | grep -q "$1"; then
		echo will not fsck "$1"
	else
		sudo fsck -y "$1" || {
			[ "$?" -eq 1 ] || return 1
		}
	fi
	chroot_mount "$1" "$2" || return 1
	status=0
	if [ -f /run/mount/"$2"/etc/os-release ]; then
		# shellcheck source=/etc/os-release
		. /run/mount/"$2"/etc/os-release
		echo "Found $PRETTY_NAME"
		for u in $managers; do
			if ! sudo chroot /run/mount/"$2" sh -c "command -v $u" >/dev/null; then
				continue
			fi

			echo --- "$u" ---
			if c=$(action_get "$u"); then
				echo Action: "$c"
				sudo chroot /run/mount/"$2" sh -lc "$c" || status=$?
			fi
			break
		done
		if [ "$status" -eq 0 ]; then
			MTP=/run/mount/$2 build-uefi.sh || status=$?
		fi
	else
		echo "Skipped non-linux"
	fi
	chroot_umount "$1" "$2" || return 1
	return "$status"
}

local_upgrade() 
{
	u=""
	c=""
	for u in $managers; do
		if ! command -v "$u" 2>/dev/null; then 
			continue
		fi

		echo --- "$u" ---
		if c=$(action_get "$u"); then
			echo Action: "$c"
			sudo sh -lc "$c" || return 1
		fi
		break
	done
	build-uefi.sh
}

chroot_upgrade_one() 
{
	t=""
	n=""
	d=""
	if [ -e "$1" ]; then
		t=$(sudo lsblk -lno FSTYPE "$1")
		n=$(basename "$1")
		d=$(readlink -f "$1")
		# skip local
		if mount | grep -q "$d on / type"; then
			local_upgrade
			return $?
		fi

		case $t in
			ext*)
				chroot_upgrade "$d" "$n" || return 1
				;;
			vfat|swap|btrfs|ntfs)
				echo "Skip $n: type $t at $d"
				;;
			*)
				echo "$n: type $t unhandled $d"
				return 1
				;;
		esac
	fi
	return 0
}

chroot_upgrade_all() 
{
	result=0
	for f in /dev/disk/by-label/*; do
		basename=$(basename "$f")
		echo "*** $basename begin ***"
		chroot_upgrade_one "$f" || {
			echo "FAIL: $f" >&2
			result=1
		}
		echo "*** $basename end ***"
		echo
	done
	if command -v flatpak > /dev/null; then
		flatpak update -y || result=1
	fi
	return "$result"
}

usage() 
{
	echo "Usage: $basename all | [partition]"
}

chroot_upgrade_args() 
{
	result=0
	while [ $# -gt 0 ]; do
		basename=$(basename "$1")
		echo "*** $basename begin ***"
		chroot_upgrade_one /dev/disk/by-label/"$1" || {
			echo "FAIL: $1" >&2
			result=1
		}
		echo "*** $basename end ***"
		shift 
	done
	return "$result"
}

case $1 in
	"") usage ;;
	all) check_esp && chroot_upgrade_all ;;
	*) check_esp && chroot_upgrade_args "$@" ;;
esac
