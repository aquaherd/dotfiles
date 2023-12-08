#!/bin/sh
# name=$(hostname -s)
# barriers -f --no-tray --debug INFO --name "${name}" --enable-crypto \
#    -c "${HOME}".config/barrier/"${name}".conf \
#    --address 127.0.0.1:24800

ssh pg2pc198 'echo start > /usr/local/share/mode.html'

if ssh-add -l | grep -q Auth; then
    echo 'keys ok'
else
    ssh-add -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so < /dev/zero
fi

if sess | grep -q zsc; then
    echo OK
else
    while ! ssh zsc echo OK; do
	sleep 1m
    done
fi
