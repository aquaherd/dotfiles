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

CMDLINE="root=LABEL=$ID ro quiet splash"
VMLINUZ="$MTP/vmlinuz"
INITRD="$MTP/initrd.img"
STUB="$MTP/usr/lib/systemd/boot/efi/linuxx64.efi.stub"
[ -f "$STUB" ] || STUB=/usr/lib/systemd/boot/efi/linuxx64.efi.stub
[ -f "$STUB" ] || STUB="$HOME/.local/lib/linuxx64.efi.stub"
# Newer stubs are linked with a non-zero PE ImageBase; add_section VMAs
# must sit above it or objcopy refuses ("section below image base").
# Layout relative to ImageBase is unchanged since the 246 stub.
BASE_HEX=$(objdump -p "$STUB" |
	sed -n 's/^ImageBase[[:space:]]*0*\([0-9a-fA-F][0-9a-fA-F]*\).*/\1/p')
if [ -z "$BASE_HEX" ]; then
	echo "Cannot determine ImageBase of $STUB" >&2
	exit 1
fi
BASE=$((0x$BASE_HEX))
VMA() { printf '0x%x' $((BASE + $1)); }
BMP="$HOME/.local/lib/$ID.bmp"
set -- "$STUB"
if [ -f "$BMP" ]; then
	set -- --add-section ".splash=$BMP" --change-section-vma ".splash=$(VMA 0x40000)" "$STUB"
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
    --add-section .osrel="$OS_RELEASE" --change-section-vma ".osrel=$(VMA 0x20000)" \
    --add-section .cmdline="$WORKDIR/cmdline" --change-section-vma ".cmdline=$(VMA 0x30000)" \
    --add-section .linux="$VMLINUZ" --change-section-vma ".linux=$(VMA 0x2000000)" \
    --add-section .initrd="$INITRD" --change-section-vma ".initrd=$(VMA 0x3000000)" \
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
	EFI_ENTRIES=$(efibootmgr -v)
fi

# Multi-boot default selection: the ESP carries EFI/default.txt (shown as
# \EFI\DEFAULT.TXT by DOS tools) containing the ESP path of the loader to
# boot first, e.g. "\EFI\Linux\debian.efi", or just the distro ID
# "debian". Any distro's maintenance run honours it; others leave the
# BootOrder alone. Also repairs BootOrder after grub package upgrades
# (grub-install pushes GRUB entries back to the front).
DEFAULT_FILE=$(findmnt -rn -M /boot/efi -o TARGET)/EFI/default.txt
if ! sudo -n test -f "$DEFAULT_FILE"; then
	echo "No $DEFAULT_FILE, leaving BootOrder untouched"
	exit 0
fi
sel=$(sudo -n cat -- "$DEFAULT_FILE" 2>/dev/null |
	tr -d ' \t\r\n' | tr '[:upper:]' '[:lower:]' |
	sed -e 's|\\|/|g' -e 's|^/*||' -e 's|^efi/||')
case $sel in
	"$ID"|"$ID.efi")	sel="linux/$ID.efi";;
esac
FIRST_NUM=$(printf '%s\n' "$EFI_ENTRIES" | tr '[:upper:]' '[:lower:]' |
	awk -v sel="$sel" '
		match($0, /file\([^)]*\)/) {
			p = substr($0, RSTART + 5, RLENGTH - 6)
			gsub(/\\/, "/", p)
			sub(/^\/+/, "", p)
			sub(/^efi\//, "", p)
			if (p == sel) {
				print substr($1, 5, 4)
				exit
			}
		}')
if [ -z "$FIRST_NUM" ]; then
	echo "No EFI entry matches '$sel' from $DEFAULT_FILE, leaving BootOrder untouched" >&2
	exit 0
fi
ORDER=$(printf '%s\n' "$EFI_ENTRIES" | sed -n 's/^BootOrder: //p' |
	tr ',' '\n' | grep -v "^$FIRST_NUM$" | paste -sd,)
if [ -n "$ORDER" ]; then
	ORDER="$FIRST_NUM,$ORDER"
else
	ORDER="$FIRST_NUM"
fi
sudo efibootmgr --bootorder "$ORDER" >/dev/null
echo "BootOrder: $ORDER"
