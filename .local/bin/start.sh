#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
host=win106
usbf=$host

if [ $# -eq 1 ]; then
    host=$1
    usbf=zsc
fi

for d in Firmware Logfiles; do
        if mountpoint -q ~/$d; then
                echo unmounting \~/$d ...
                fusermount -u ~/$d
        fi
        echo mounting ${host}:$d to \~/$d ...
        sshfs ${host}:$d ~/$d
done
echo $host > "$hostpath"
ssh -O forward $host '2323 192.168.194.40:23'
ssh -O forward $usbf "3240 $host:3240"
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
