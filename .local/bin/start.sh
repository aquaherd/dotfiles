#!/bin/sh
hostpath="$XDG_RUNTIME_DIR/host"
host=win106

if [ $# -eq 1 ]; then
    host=$1
fi
ssh $host echo OK
for d in Firmware Logfiles; do
        if mountpoint -q ~/$d; then
                echo unmounting \~/$d ...
                fusermount -u ~/$d
        fi
        echo mounting ${host}:$d to \~/$d ...
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
