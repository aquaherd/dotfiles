#!/bin/sh
appname=$(basename "$0")
hostpath="$XDG_RUNTIME_DIR/host"
die()
{
    echo "$appname: $*"
    exit 1
}
for d in Firmware Logfiles; do
    echo unmount $d
    fusermount -u ~/$d || echo 'was not mounted'
done
if test -f "$hostpath"; then
    read -r host < "$hostpath" || die "no host set"
    ssh -qO exit "$host" || echo "did not quit"
    rm -f "$hostpath"
    echo "exit session $host"
fi
echo "OK"
