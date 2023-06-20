#!/bin/sh
# Original: https://github.com/ErnyTech/Unified-Kernel-Image
OS_RELEASE=$MTP/etc/os-release
. $OS_RELEASE

echo "Building image for $PRETTY_NAME"

# Create file for kernel command line, provide at least the root parameter
echo "root=LABEL=$ID rw rootfstype=ext4 quiet" > /tmp/kernel-command-line.txt

# Set the splash image, /sys/firmware/acpi/bgrt/image is the vendor logo taken from ACPI in BMP image format
SPLASH="/sys/firmware/acpi/bgrt/image"

# Set the kernel image path (enter the path for your operating system)
VMLINUZ="$MTP/vmlinuz"

# Set the initrd image path (enter the path for your operating system)
INITRD="$MTP/initrd.img"

# Set the EFI STUB path, the default value should be good for the most users 
STUB="$HOME/.local/lib/linuxx64.efi.stub"

TARGET=/boot/efi/EFI/Linux/$ID.efi

if [ ! -e $VMLINUZ -o ! -e $INITRD ]; then
	echo "Setup invalid"
	exit 1
fi

if [ ! -d /sys/firmware/efi ]; then
    echo "BIOS boot, skipping efimgr"
    exit 0
fi

if [ -e $TARGET ]; then
	if [ $TARGET -nt $VMLINUZ -a $TARGET -nt $INITRD ]; then
		echo "$TARGET is already up-to-date."
		exit 0
	fi
else
	echo "Will update $TARGET"
fi

if [ -n "$MTP"  ]; then
	cd $MTP
fi
sudo chmod +r $VMLINUZ $INITRD
objcopy \
    --add-section .osrel="$OS_RELEASE" --change-section-vma .osrel=0x20000 \
    --add-section .cmdline="/tmp/kernel-command-line.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .splash="$SPLASH" --change-section-vma .splash=0x40000 \
    --add-section .linux="$VMLINUZ" --change-section-vma .linux=0x2000000 \
    --add-section .initrd="$INITRD" --change-section-vma .initrd=0x3000000 \
    "$STUB" "/tmp/$ID.efi" || ( echo FAIL && exit 1 )

sudo cp -vu /tmp/$ID.efi $TARGET && rm /tmp/$ID.efi

if efibootmgr | cut -d' ' -f 2 | grep -q $ID; then
	echo "EFI entry already present"
else
	echo "Add EFI entry for $ID"
	sudo efibootmgr --disk /dev/sda --part 6 --create-only --label $ID --verbose --loader "\\EFI\\Linux\\$ID.efi"
fi
