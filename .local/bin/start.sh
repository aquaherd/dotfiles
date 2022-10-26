#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
if [ $# -eq 0 ]; then
    echo "usage: start.sh HOST"
    exit 1
fi
host=$1
ssh $host echo OK
for d in Firmware Logfiles; do
    if mountpoint -q ~/$d; then
        echo "unmounting \~/$d ..."
        fusermount -u ~/$d
    fi
    echo "mounting ${host}:$d to \~/$d ..."
    sshfs ${host}:$d ~/$d
done
echo $host > "$hostpath"
for b in $(sudo usbip list -r localhost 2> /dev/null |grep UART|cut -d':' -f1); do
    case $b in
        *-*)
            echo "attaching UART $b"
            sudo usbip attach -r localhost -b $b
            ;;
        *) continue;;
    esac
done
echo OK
