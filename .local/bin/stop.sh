#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
for d in Firmware Logfiles; do
    echo unmount $d
    fusermount -u ~/$d || echo 'was not mounted'
done
if test -f "$hostpath"; then
    read host < "$hostpath" || echo no host set
    echo "exit session $host"
    ssh -qO exit "$host"
    rm "$hostpath"
fi
echo OK
