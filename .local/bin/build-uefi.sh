#!/bin/sh

OS_RELEASE=/usr/lib/os-release
. $OS_RELEASE

# Create file for kernel command line, provide at least the root parameter
echo "root=LABEL=$ID rw quiet splash" > /tmp/kernel-command-line.txt

# Set the splash image, /sys/firmware/acpi/bgrt/image is the vendor logo taken from ACPI in BMP image format
SPLASH="$HOME/.local/lib/efi.bmp"

# Set the kernel image path (enter the path for your operating system)
VMLINUZ="/vmlinuz"

# Set the initrd image path (enter the path for your operating system)
INITRD="/initrd.img"

# Set the EFI STUB path, the default value should be good for the most users 
STUB="$HOME/.local/lib/linuxx64.efi.stub"

objcopy \
    --add-section .osrel="$OS_RELEASE" --change-section-vma .osrel=0x20000 \
    --add-section .cmdline="/tmp/kernel-command-line.txt" --change-section-vma .cmdline=0x30000 \
    --add-section .splash="$SPLASH" --change-section-vma .splash=0x40000 \
    --add-section .linux="$VMLINUZ" --change-section-vma .linux=0x2000000 \
    --add-section .initrd="$INITRD" --change-section-vma .initrd=0x3000000 \
    "$STUB" "$ID.efi"

sudo cp -vu $ID.efi /boot/efi/EFI/Linux
