# this is a posix shell fragment for inclusion only

fix_desktop() # in case you start without display manager
{
	if [ -z "$DESKTOP_SESSION" ]; then
		if [ -n "$SWAYSOCK" ]; then
			export DESKTOP_SESSION=sway
		elif [ -n "$I3SOCK" ]; then
			export DESKTOP_SESSION=i3
		elif [ -z "$DISPLAY"  ]; then
			export DESKTOP_SESSION=none
			return
		elif [ -n "$WSL_DISTRO_NAME" ]; then
			if [ "$WSL2_GUI_APPS_ENABLED" = "1" ]; then
				export DESKTOP_SESSION=wslg
			else
				export DESKTOP_SESSION=none 
			fi
		else
			DESKTOP_SESSION="$(wmname)"
			export DESKTOP_SESSION
		fi
	fi

	if [ -z "$WAYLAND_DISPLAY" ]; then
		#x11
		if [ -z "$PRIMARY" ]; then
			if [ "$(xrdb -q|wc -l)" -eq 0 ]; then
				xrdb -merge ~/.Xresources
			fi

			PRIMARY=$(xrdb -q | grep Xdisplay.primary | cut -f2)
			SECONDARY=$(xrdb -q | grep Xdisplay.secondary | cut -f2)
			export PRIMARY SECONDARY
		fi
	fi
}

get_session()
{
	if [ -z "$DESKTOP_SESSION" ]; then
		fix_desktop
	fi
	echo "$DESKTOP_SESSION"
}

CACHE="$XDG_RUNTIME_DIR/$(get_session)/cache"
autostart_common()
{
	fix_desktop
	mkdir -p "$CACHE"
	exec > "$CACHE"/autostart.log
	exec 2>&1
	randr_restore
	restore_backdrop
	if ! pidof runsvdir && [ -d "$HOME/.local/service" ]; then
		# Start local services if runsv
		start runsvdir ~/.local/service
	fi
}

start()
{
	exec >> "$CACHE"/autostart.log
	exec 2>&1
	if [ -f "$CACHE/$1.pid" ]; then
		echo "start: $* already running"
		return
	fi
	echo "start: $*"
	"$@" &
	pid=$!
	disown $pid
	echo $pid > "$CACHE/$1.pid"
}

start_oneshot()
{
	exec >> "$CACHE"/autostart.log
	exec 2>&1
	echo "start: $*"
	"$@" 
}

gset()
{
	start_oneshot gsettings set org.gnome.desktop.interface "$1" "$2"
}

closeall_common()
{
	for d in "$CACHE"/*.pid; do 
		read -r pid < "$d"
		kill "$pid" || echo "$d was not running."
		rm -f "$d"
	done
}

randr_bspwm()
{
	~/.config/bspwm/xrandr.sh "$1"
}

randr_sway()
{
	case $1 in 
		single) swaymsg output \$secondary disable;;
		dual) swaymsg output \$secondary enable;;
	esac 
}

randr_default()
{
	case $1 in
		single) xrandr --output "$SECONDARY" --off ;;
		dual) xrandr --output "$SECONDARY" --auto --left-of "$PRIMARY" ;;
	esac
}

randr()
{
	fix_desktop
	read -r oldrandr < ~/.cache/xrandr
	echo "randr: $PRIMARY $SECONDARY randr_${DESKTOP_SESSION}  $*"
	"randr_${DESKTOP_SESSION}" "$*" || randr_default "$*"
	echo "$*" > .cache/xrandr
	if [ "$*" != "$oldrandr" ]; then
		DST=nosuchimage restore_backdrop
	fi

}

randr_restore()
{
	r="single"
	read -r r < ~/.cache/xrandr || true
	randr "$r"
}

DST=/usr/local/share/backgrounds/$(id -un)
restore_backdrop()
{
	fix_desktop
	if [  ! -f "$DST" ]; then
		echo "$DST not found. Shuffle."
		update-hsetroot.sh -s
	else
		update-hsetroot.sh -r
	fi 
}

ask()
{
	fix_desktop
	case $DESKTOP_SESSION in
		sway)
			wofi -idp "$1"
			;;
		hikari|wayfire)
			# dont know how to determine current monitor in hikari
			dmenu-wl -i -p "$1" -fn 'Iosevka 15' -nb '#44475a' -sb '#bd93f9' -h 30 -b
			;;
		gnome)
			if [ -n "$WAYLAND_DISPLAY" ]; then
				wofi -idp "$1"
			else
				dmenu -i -p "$1"
			fi
			;;
		none)
			fzf
			;;
		wslg)
			wofi -idp "$1"
			;;
		*)
			dmenu -b -i -p "$1"
			;;
	esac
}
