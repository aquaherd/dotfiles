#!/bin/sh
appname=$(basename "$0")
hostpath="$XDG_RUNTIME_DIR/host"
die()
{
    echo "$appname: $*"
    exit 1
}
for d in Firmware Logfiles; do
    if fusermount -u ~/$d 2> /dev/null; then
	echo "$d: unmounted"
    fi
done
if test -f "$hostpath"; then
    read -r host < "$hostpath" || die "no host set"
    rm -f "$hostpath"
    ssh -qO exit "$host" || echo "did not quit"
    echo "exit session $host"
fi
echo "OK"
