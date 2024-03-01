#!/bin/bash
# PATH fixups
case ":$PATH:" in
	:$HOME/.local/bin:) ;;
	*) PATH+=:$HOME/.local/bin
		export PATH
		;;
esac

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
# X11
if command -v wsld > /dev/null; then
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
	xrdb -merge ~/.Xresources
	export DBUS_SESSION_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
	if ! pgrep dbus > /dev/null; then
		echo 'launching dbus...'
		dbus-daemon --session --fork --address=$DBUS_SESSION_ADDRESS
	fi
fi
# SSH
if command -v wsl2-ssh-agent > /dev/null; then
	export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.sock 
	if ! pgrep wsl2-ssh-agent > /dev/null; then
		echo 'launching ssh-agent...'
		eval "$(wsl2-ssh-agent --socket $SSH_AUTH_SOCK)"
	fi
fi

