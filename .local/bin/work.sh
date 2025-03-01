#!/bin/sh
# name=$(hostname -s)
# barriers -f --no-tray --debug INFO --name "${name}" --enable-crypto \
#    -c "${HOME}".config/barrier/"${name}".conf \
#    --address 127.0.0.1:24800

ssh pg2pc198 'echo start > /usr/local/share/mode.html'

if ssh-add -l | grep -q Auth; then
	echo 'keys ok'
else
	for d in /usr/lib /usr/lib/$(uname -m)-linux-gnu; do
		s="$d/opensc-pkcs11.so"
		echo "trying $s"
		if test -f "$s"; then
			ssh-add -s "$s" 
			break
		fi
	done
fi

# if sess | grep -q zsc; then
# 	echo OK
# else
# 	while ! ssh zsc echo OK; do
# 		sleep 1m
# 	done
# fi

if sess | grep -q zsc; then
	echo OK
else
	# sshuttle -r zsc 10.0.0.0/8 --dns -HN --daemon --pidfile="$XDG_RUNTIME_DIR"/sshuttle.pid
	sshuttle -r zsc 10.0.0.0/8 -HN --daemon --pidfile="$XDG_RUNTIME_DIR"/sshuttle.pid
fi
