#!/bin/sh
# run minimum needful things before starting the WM
# see ~/.local/bin/startX

test -f ~/.Xresources && xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    sudo mkdir -p $XDG_RUNTIME_DIR
    sudo chown $USER:$USER $XDG_RUNTIME_DIR
    chmod 0700 $XDG_RUNTIME_DIR
fi
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval $(ssh-agent)
fi
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    exec dbus-run-session $1
fi
exec $1
