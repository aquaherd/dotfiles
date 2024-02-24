#!/bin/bash
if command -v wsld > /dev/null; then
	export DISPLAY=:0
	if ! pgrep wsld > /dev/null; then
		nohup wsld > /dev/null < /dev/null 2>&1 &
		disown
		# sleep until $DISPLAY is up
		while ! xset q > /dev/null 2>&1 ; do
			sleep 0.3
		done	
	fi
	xrdb -merge ~/.Xresources
	# create XDG
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
	export DBUS_SESSION_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
	if ! pgrep dbus > /dev/null; then
		dbus-daemon --session --fork --address=$DBUS_SESSION_ADDRESS
	fi
fi

if command -v wsl2-ssh-agent > /dev/null; then
	eval "$(wsl2-ssh-agent)"
fi
