#!/bin/sh
# Original: https://github.com/ErnyTech/Unified-Kernel-Image
set -e

MTP=${MTP:-}
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

if ! findmnt -rn -M /boot/efi -t vfat -O rw >/dev/null; then
	echo "Cannot build EFI image: /boot/efi must be mounted read-write as vfat." >&2
	exit 1
fi

CMDLINE="root=LABEL=$ID rw rootfstype=ext4 vsyscall=emulate quiet"
VMLINUZ="$MTP/vmlinuz"
INITRD="$MTP/initrd.img"
STUB="$HOME/.local/lib/linuxx64.efi.stub"
BMP="$HOME/.local/lib/$ID.bmp"
set -- "$STUB"
if [ -f "$BMP" ]; then
	set -- --add-section ".splash=$BMP" --change-section-vma .splash=0x40000 "$STUB"
	CMDLINE="$CMDLINE splash vt.handoff=7 gfxpayload=keep"
fi
TARGET=/boot/efi/EFI/Linux/$ID.efi
ESP=$(findmnt -rn -M /boot/efi -o SOURCE)
DISK=/dev/$(lsblk -dnro PKNAME "$ESP")
PART=$(lsblk -dnro PARTN "$ESP")
PARTUUID=$(lsblk -dnro PARTUUID "$ESP")
if [ ! -b "$DISK" ] || [ -z "$PART" ] || [ -z "$PARTUUID" ]; then
	echo "Cannot determine EFI disk and partition for $ESP." >&2
	exit 1
fi
if [ ! -e "$VMLINUZ" ] || [ ! -e "$INITRD" ]; then
	echo "Setup invalid $VMLINUZ / $INITRD" >&2
	exit 1
fi

EFI_ENTRIES=$(efibootmgr -v)
WORKDIR=$(mktemp -d)
ESP_TMP=
cleanup()
{
	if [ -n "$ESP_TMP" ]; then
		sudo rm -f -- "$ESP_TMP"
	fi
	rm -f -- "$WORKDIR/cmdline" "$WORKDIR/image.efi"
	rmdir -- "$WORKDIR"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
printf '%s\n' "$CMDLINE" > "$WORKDIR/cmdline"

echo "Building image for $PRETTY_NAME disk $DISK part $PART"
sudo objcopy \
    --add-section .osrel="$OS_RELEASE" --change-section-vma .osrel=0x20000 \
    --add-section .cmdline="$WORKDIR/cmdline" --change-section-vma .cmdline=0x30000 \
    --add-section .linux="$VMLINUZ" --change-section-vma .linux=0x2000000 \
    --add-section .initrd="$INITRD" --change-section-vma .initrd=0x3000000 \
    "$@" "$WORKDIR/image.efi"

sudo mkdir -p -- "$(dirname "$TARGET")"
ESP_TMP=$(sudo mktemp "$TARGET.XXXXXX")
sudo install -m 0644 "$WORKDIR/image.efi" "$ESP_TMP"
sudo cmp "$WORKDIR/image.efi" "$ESP_TMP"
sudo sync -f "$ESP_TMP"
sudo mv -f -- "$ESP_TMP" "$TARGET"
ESP_TMP=
sudo sync -f /boot/efi

if printf '%s\n' "$EFI_ENTRIES" | grep -Fi -- "$PARTUUID" |
	grep -Fiq -- "File(\\EFI\\Linux\\$ID.efi)"; then
	echo "EFI entry already present"
else
	echo "Add EFI entry for $ID"
	sudo efibootmgr --disk "$DISK" --part "$PART" --create-only \
		--label "$ID" --verbose --loader "\\EFI\\Linux\\$ID.efi"
fi
