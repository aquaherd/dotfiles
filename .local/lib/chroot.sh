chroot_mount() {
	echo "chroot_mount $1 to $2"
	sudo mkdir -p /run/mount/$2
    sudo mount -t auto $1 /run/mount/$2
    local d
	for d in boot/efi dev etc/resolv.conf proc sys; do
		if [ -e /run/mount/$2/$d ]; then
			sudo mount -o bind /$d /run/mount/$2/$d
		fi
	done
}

chroot_umount() {
	echo "chroot_umount $1 from $2"
    sudo fstrim -v /run/mount/$2
    sudo umount --recursive /run/mount/$2 && sudo rmdir /run/mount/$2
}
