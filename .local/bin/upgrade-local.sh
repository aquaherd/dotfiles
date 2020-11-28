#!/bin/sh

managers="apk apt dnf kiss pacman swupd xbps-install yum"

action_get() {
    case $1 in
    apk) echo 'apk upgrade && cp -vu /boot/*-lts /boot/efi/EFI/alpine/' ;;
    apt) echo 'apt update && apt full-upgrade -y && apt autoremove --purge -y && apt-get autoclean' ;;
    dnf) echo 'dnf upgrade && dnf autoremove' ;;
    kiss) echo 'KISS_PROMPT=0 kiss u && KISS_PROMPT=0 kiss u' ;;
    pacman) echo 'pacman -Syua' ;;
    swupd) echo 'swupd update' ;;
    xbps-install) echo 'xbps-install -Syu' ;;
    yum) echo "yum upgrade" ;;
    *) return 1 ;;
    esac
}

chroot_upgrade() {
    echo "Checking $1 $2"
    if mount | grep -q $1; then
        echo unmount $1
        sudo umount $1 || echo cant unmount $1
        return
    fi
    sudo fsck -y $1
    sudo mkdir -p /run/mount/$2
    sudo mount -t auto $1 /run/mount/$2

    if [ -f /run/mount/$2/bin/sh ]; then
        for d in boot/efi dev etc/resolv.conf proc sys; do
            if [ -e /run/mount/$2/$d ]; then
                sudo mount -o bind /$d /run/mount/$2/$d
            fi
        done

        for u in $managers; do
            a=$(sudo chroot /run/mount/$2 which $u 2>/dev/null) || continue

            echo --- $u ---
            if c=$(action_get $u); then
                echo Action: $c
                sudo chroot /run/mount/$2 sh -lc "$c"
            fi
            break
        done
    fi
    #sudo fstrim -v /run/mount/$2
    sudo umount --recursive /run/mount/$2 && sudo rmdir /run/mount/$2
    echo
}

local_upgrade() {
        for u in $managers; do
            a=$(which $u 2>/dev/null) || continue

            echo --- $u ---
            if c=$(action_get $u); then
                echo Action: $c
                sudo sh -lc "$c"
            fi
            break
        done
}

chroot_upgrade_one() {
    if [ -e $1 ]; then
        t=$(lsblk -lno FSTYPE $1)
        n=$(basename $1)
        d=$(readlink -f $1)
        # skip local
        if mount | grep -q "$d on / type"; then
            local_upgrade
        fi

        case $t in
        ext*)
            chroot_upgrade $d $n && return 0 || return 1
            ;;
        *)
            ;;
        esac
    fi

    return 1
}

chroot_upgrade_all() {
    for f in /dev/disk/by-label/*; do
        chroot_upgrade_one $f || echo FAIL
    done
}

usage() {
    echo "Usage: $(basename $0) all | [partition]"
}

chroot_upgrade_args() {
    while [ $# -gt 0 ]; do
        chroot_upgrade_one /dev/disk/by-label/$1 || echo FAIL
        shift 
    done
}

case $1 in
    "") usage ;;
    all) chroot_upgrade_all ;;
    *) chroot_upgrade_args $* ;;
esac
