#!/bin/bash
if command -v wsld > /dev/null; then
	if ! pgrep wsld > /dev/null; then
		export DISPLAY=:0
		nohup wsld > /dev/null < /dev/null 2>&1 &
		disown
		# sleep until $DISPLAY is up
		while ! xset q > /dev/null 2>&1 ; do
			sleep 0.3
		done	
		xrdb -merge ~/.Xresources
		if [ -z "$DBUS_SESSION_ADDRESS" ]; then
			export DBUS_SESSION_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
			if [ ! -S $XDG_RUNTIME_DIR/bus ]; then
				dbus-daemon --session --fork --address=$DBUS_SESSION_ADDRESS
			fi
		fi
	fi
fi
