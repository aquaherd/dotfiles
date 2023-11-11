#!/bin/sh
# Original: https://github.com/ErnyTech/Unified-Kernel-Image
OS_RELEASE=$MTP/etc/os-release
# shellcheck source=/etc/os-release
. "$OS_RELEASE"
if [ -z "$ID" ]; then
	echo "ID not set"
	exit 1
fi

if [ ! -d /sys/firmware/efi ]; then
    echo "BIOS boot, skipping efimgr"
    exit 0
fi

echo "root=LABEL=$ID rw rootfstype=ext4 quiet splash" > /tmp/kernel-command-line.txt
VMLINUZ="$MTP/vmlinuz"
INITRD="$MTP/initrd.img"
STUB="$HOME/.local/lib/linuxx64.efi.stub"
BMP="$HOME/.local/lib/$ID.bmp"
if [ -f "$BMP" ]; then
	SPLASH="--add-section .splash=$BMP --change-section-vma .splash=0x40000"
else
	SPLASH=""
fi
TARGET=/boot/efi/EFI/Linux/$ID.efi
DISK=/dev/$(lsblk -no pkname /dev/disk/by-label/EF00)
PART=$(stat -c '%T' "$(realpath /dev/disk/by-label/EF00)")
if [ ! -e "$VMLINUZ" ] || [ ! -e "$INITRD" ]; then
	echo "Setup invalid"
	exit 1
fi

if [ -e $TARGET ]; then
	if test "$TARGET" -nt "$VMLINUZ" && test "$TARGET" -nt "$INITRD"; then
		echo "$TARGET is already up-to-date."
		exit 0
	fi
else
	echo "Will update $TARGET"
fi

if [ -n "$MTP"  ]; then
	cd "$MTP" || exit 2
fi

echo "Building image for $PRETTY_NAME disk $DISK part $PART"
sudo chmod +r "$VMLINUZ" "$INITRD"
objcopy "$SPLASH" \
    --add-section .osrel="$OS_RELEASE" --change-section-vma .osrel=0x20000 \
    --add-section .cmdline="/tmp/kernel-command-line.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="$VMLINUZ" --change-section-vma .linux=0x2000000 \
    --add-section .initrd="$INITRD" --change-section-vma .initrd=0x3000000 \
    "$STUB" "/tmp/$ID.efi" || ( echo FAIL && exit 1 )

sudo cp -vu /tmp/$ID.efi $TARGET && rm /tmp/$ID.efi

if efibootmgr | cut -d' ' -f 2 | grep -q $ID; then
	echo "EFI entry already present"
else
	echo "Add EFI entry for $ID"
	sudo efibootmgr --disk "$DISK" --part "$PART" --create-only \
		--label "$ID" --verbose --loader "\\EFI\\Linux\\$ID.efi"
fi
