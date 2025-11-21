#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
if test -f "$hostpath"; then
	stop.sh
fi
all='win105 win106 win107 win108 win109 win126 win131 win200 win246 win247 win248 win249'
if [ $# -eq 0 ]; then
	host=$(echo "$all" | tr " " "\n" | fzf) || exit 1
else
	host=$1
fi
ssh "$host" \
	-o ServerAliveInterval=15 \
	-L '127.0.0.1:2322:127.0.0.1:2222' \
	-L '127.0.0.1:2323:192.168.184.40:23' \
	-L '127.0.0.1:2324:127.0.0.1:2324' \
	-L '127.0.0.1:3240:localhost:3240' \
	-L '127.0.0.1:20000:localhost:20000' \
	-L '127.0.0.1:49152:192.168.184.40:49152' \
	-L '127.0.0.1:50101:192.168.184.40:50101' \
	-L '127.0.0.1:8192:localhost:8192' \
	echo OK

pkill -f 'sshfs -o reconnect win'
for d in Firmware Logfiles; do
	echo "mounting ${host}:$d to \~/$d ..."
	sshfs -o reconnect "${host}":$d ~/$d
done
echo "$host" >"$hostpath"
reusb.sh
if grep -q microsoft /proc/version; then
	sudo modprobe vhci_hcd ftdi_sio || exit 1

	echo 'waiting for UARTs to settle'
	sleep 5
	sudo chown -v root:dialout /dev/tty[AU]*
	sudo chmod -v g+rw /dev/tty[AU]*
fi
echo OK
