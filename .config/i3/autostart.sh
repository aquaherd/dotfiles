#!/bin/bash 
PATH+=:~/.local/bin
# shellcheck source=../../.local/lib/dmenu-lib.sh
. ~/.local/lib/dmenu-lib.sh
autostart_common

start_oneshot xsetroot -cursor_name left_ptr
start_oneshot xrdb -merge ~/.Xresources

start dunst
start i3-autotiling 
start redshift
start xsettingsd

BARRIERRC=~/.config/barrier/${HOSTNAME}.conf
if test -f "$BARRIERRC"; then
    start barriers -f --debug INFO --name "$HOSTNAME" --enable-crypto -c "$BARRIERRC" --address '[127.0.0.1]:24800'
else
    echo "$BARRIERRC does not exist"
fi

test -z "$XRDP_SESSION" && start picom 
