#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
if test -f "$hostpath"; then
	stop.sh
fi
all='win105 win106 win107 win108 win109 win126 win131 win200 win246 win247 win248 win249'
if [ $# -eq 0 ]; then
	host=$(echo "$all" |tr " " "\n"| fzf) || exit 1
else
	host=$1
fi
ssh "$host" \
	-L '127.0.0.1:2323:192.168.184.40:23' \
	-L '127.0.0.1:3240:localhost:3240' \
	-L '127.0.0.1:8192:localhost:8192' \
	-L '127.0.0.1:50101:192.168.184.40:50101' \
	echo OK

for d in Firmware Logfiles; do
	if mountpoint -q ~/$d > /dev/null; then
		echo "unmounting \~/$d ..."
		fusermount -u ~/$d
	fi
	echo "mounting ${host}:$d to \~/$d ..."
	sshfs -o reconnect,ServerAliveInterval=15 "${host}":$d ~/$d
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
if test -c /dev/ttyUSB0 && [ 'root' = "$(stat -c%G /dev/ttyUSB0)" ]; then
	echo 'waiting for UARTs to settle'
	sleep 5
	sudo chown -v root:dialout /dev/ttyUSB*
	sudo chmod -v g+rw /dev/ttyUSB*
fi
echo OK
