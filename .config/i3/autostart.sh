#!/bin/bash 
PATH+=:~/.local/bin
# shellcheck source=/dev/null
. ~/.local/lib/dmenu-lib.sh
randr_restore
restore_backdrop
pids="$XDG_RUNTIME_DIR/i3"
mkdir "$pids"
exec > "$pids/autostart.log"
exec 2>&1
start()
{
    echo "restart: $*"
    "$@" &
    pid=$!
    disown $pid
    echo $pid > "$pids/$1.pid"

}
for d in "$pids"/*.pid; do 
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
BARRIERRC=~/.config/barrier/${HOSTNAME}.conf
if test -f "$BARRIERRC"; then
    start barriers -f --debug INFO --name "$HOSTNAME" --enable-crypto -c "$BARRIERRC" --address '[127.0.0.1]:24800'
else
    echo "$BARRIERRC does not exist"
fi

# e.g. alpine has no user services
test -d "$HOME/.local/service" && if ! pidof runsvdir; then
        start runsvdir ~/.local/service
fi
