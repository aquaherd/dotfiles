#!/bin/bash
# Sanity checks
if [[ -n "$container" ]]; then
	return
fi

if [[ -n "$DEV_CONTAINER_NAME" ]]; then
	return
fi

if ! grep -q microsoft /proc/version; then
	return
fi
echo "wsl..."
# PATH fixups
LOCAL_BIN=$HOME/.local/bin
if ! [[ $PATH =~ $LOCAL_BIN ]]; then
	PATH=$LOCAL_BIN:$PATH
	export PATH
fi
# XDG
if [[ -z "$XDG_RUNTIME_DIR" ]]; then
	export XDG_RUNTIME_DIR=/run/user/$UID
	if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
		export XDG_RUNTIME_DIR=/run/shm/$UID
		if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
			mkdir -m 0700 "$XDG_RUNTIME_DIR"
		fi
	fi
else
	export PROFILE_LOADED=1
fi
# SSH
if command -v wsl2-ssh-agent > /dev/null; then
	export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.sock 
	if ! pgrep wsl2-ssh-agent > /dev/null; then
		echo 'launching ssh-agent...'
		eval "$(wsl2-ssh-agent --socket "$SSH_AUTH_SOCK")"
	fi
fi

# X11 & wayland
if [ -f ~/.bashrc.d/nodesktop ]; then
	return
fi
if [[ -z "$WAYLAND_DISPLAY" ]] && command -v wsld > /dev/null; then
	export DISPLAY=:0
	if ! pgrep wsld > /dev/null; then
		echo 'launching wsld...'
		sudo rm -rf /tmp/.X*
		nohup wsld > /dev/null < /dev/null 2>&1 &
		disown
		# sleep until $DISPLAY is up
		while ! xset q > /dev/null 2>&1 ; do
			sleep 0.3
		done	
	fi
	if command -v xrdb > /dev/null; then
		xrdb -merge ~/.Xresources
	fi

	export DBUS_SESSION_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
	export NO_AT_BRIDGE=1
	if ! pgrep dbus > /dev/null; then
		echo 'launching dbus...'
		dbus-daemon --session --fork --address="$DBUS_SESSION_ADDRESS"
	fi
	if ! dump_xsettings > /dev/null 2>&1; then
		echo 'launching xsettingsd...'
		xsettingsd > /dev/null 2>&1 &
		disown
	fi
fi
if [ -n "$DISPLAY" ] && command -v xrdb > /dev/null; then
	xrdb -query | grep -q . || xrdb -merge ~/.Xresources
fi
