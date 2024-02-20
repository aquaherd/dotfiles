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
	fi
fi
