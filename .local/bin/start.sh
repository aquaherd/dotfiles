#!/bin/sh

usage()
{
	cat <<EOF
usage: $(basename "$0") [host] [-- remote-command ...]

Start the usual SSH session and mounts. If a remote command is given, run it
on the selected host after the session is established.

Examples:
  $(basename "$0") win130
  $(basename "$0") win130 -- uname -a
  $(basename "$0") win130 -- python3 - --help < ./issues/CV12345/test_verify.py
EOF
}

hostpath="$XDG_RUNTIME_DIR/host"
all='win105 win106 win107 win108 win109 win126 win130 win131 win200 win246 win247 win248 win249'

case "${1:-}" in
	-h|--help)
		usage
		exit 0
		;;
esac

if test -f "$hostpath"; then
	stop.sh
fi

if [ $# -eq 0 ] || [ "${1:-}" = "--" ]; then
	host=$(printf '%s\n' $all | fzf) || exit 1
else
	host=$1
	shift
fi

if [ "${1:-}" = "--" ]; then
	shift
fi

ssh -n "$host" \
	-o ServerAliveInterval=15 \
	-L '127.0.0.1:2322:127.0.0.1:2222' \
	-L '127.0.0.1:2323:192.168.184.40:23' \
	-L '127.0.0.1:2324:127.0.0.1:2324' \
	-L '127.0.0.1:3240:localhost:3240' \
	-L '127.0.0.1:20000:localhost:20000' \
	-L '127.0.0.1:49152:192.168.184.40:49152' \
	-L '127.0.0.1:8192:localhost:8192' \
	echo OK || exit $?

pkill -f 'sshfs -o reconnect win'
for d in Firmware Logfiles; do
	echo "mounting ${host}:$d to \~/$d ..."
	sshfs -o reconnect "${host}":$d ~/$d || exit $?
done

echo "$host" >"$hostpath"
echo "session $host ready"

if [ $# -gt 0 ]; then
	echo "running remote command on $host: $*"
	ssh "$host" "$@"
fi
