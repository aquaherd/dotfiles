#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
if test -f "$hostpath"; then
    stop.sh
fi
all='win105 win106 win107 win108 win109 win126 win200 win246 win247 win248 win249'
if [ $# -eq 0 ]; then
    host=$(echo "$all" |tr " " "\n"| fzf) || exit 1
else
    host=$1
fi
ssh "$host" \
    -L '127.0.0.1:2323:192.168.184.40:23' \
    -L '127.0.0.1:3240:localhost:3240' \
    -L '127.0.0.1:8192:localhost:8192' \
    echo OK

for d in Firmware Logfiles; do
    if mountpoint -q ~/$d > /dev/null; then
        echo "unmounting \~/$d ..."
        fusermount -u ~/$d
    fi
    echo "mounting ${host}:$d to \~/$d ..."
    sshfs "${host}":$d ~/$d
done
echo "$host" > "$hostpath"
for b in $(sudo usbip list -r localhost 2> /dev/null |grep UART|cut -d':' -f1); do
    case $b in
        *-*)
            echo "attaching UART $b"
            sudo usbip attach -r localhost -b "$b"
            ;;
        *) continue;;
    esac
done
for u in /dev/ttyUSB?; do
    if test -c "$u"; then
        sudo chown root:dialout "$u"
        sudo chmod g+rw "$u"
    fi
done
echo OK
