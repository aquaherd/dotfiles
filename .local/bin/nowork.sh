#!/bin/sh
# name=$(hostname -s)
# barriers -f --no-tray --debug INFO --name "${name}" --enable-crypto \
#    -c "${HOME}".config/barrier/"${name}".conf \
#    --address 127.0.0.1:24800

ssh pg2pc198 'echo stop > /usr/local/share/mode.html'

ssh-add -e /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so || ssh-add -e /usr/lib/opensc-pkcs11.so 
pf="$XDG_RUNTIME_DIR"/sshuttle.pid
if [ -f "$pf" ]; then
 	read -r pid < "$pf"
	kill "$pid"
fi
ssh -O exit pg2pc198 
