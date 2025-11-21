#!/bin/sh
appname=$(basename "$0")
hostpath="$XDG_RUNTIME_DIR/host"
die()
{
    echo "$appname: $*"
    exit 1
}
pkill -f 'sshfs -o reconnect win'
if test -f "$hostpath"; then
    read -r host < "$hostpath" || die "no host set"
    rm -f "$hostpath"
    ssh -qO exit "$host" || echo "did not quit"
    echo "exit session $host"
fi
echo "OK"
