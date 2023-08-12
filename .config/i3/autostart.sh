#!/bin/bash 
PATH+=:~/.local/bin
. ~/.local/lib/dmenu-lib.sh
randr_restore
restore_backdrop
pids="$XDG_RUNTIME_DIR/i3"
mkdir "$pids"
start()
{
    echo "restart: $*"
    "$@" &
    pid=$!
    disown $pid
    echo $pid > "$pids/$1.pid"

}
for d in "$XDG_RUNTIME_DIR"/i3/*.pid; do 
    read -r pid < "$d"
    kill "$pid"
    rm "$pid"
done
start redshift
if [ -z "$XRDP_SESSION" ]; then
    start picom 
fi
start dunst
start xsettingsd -c ~/.config/i3/xsettings.conf
start i3-autotiling 
start xsetroot -cursor_name left_ptr
start stalonetray
if test -f ~/.config/barrier.sgc; then
    start barriers -f --debug INFO --name "$HOSTNAME" --enable-crypto -c ~/.config/barrier.sgc --address '[127.0.0.1]:24800'
fi
