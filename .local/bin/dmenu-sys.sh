#!/bin/sh
# shellcheck source=../lib/dmenu-lib.sh
. ~/.local/lib/dmenu-lib.sh

prompt="logout reboot poweroff lock sleep single dual boot reload"

die ()
{
	notify-send -i error "$* failed"
	kill $$
}

closeall_bspwm()
{
	# save session
	bspc wm -d >.cache/bspwm/state.json

    # graceful kill
    for d in $(bspc query -N);do 
	    bspc node "$d" -c
    done
    while [ "$(bspc query -N|wc -l)" -gt 0 ]; do
	    sleep 1
    done

    # from bspwmrc
    for f in ~/.cache/bspwm/*.pid; do
	    cmd=$(basename -s .pid "$f")
	    read -r pid < "$f"
	    kill "$pid" || pkill "$cmd" || pkill "$cmd" -9 || true
	    rm "$f"
	    echo "*** $pid:$cmd Ended ***"
    done

    # let go of panel last
    polybar-msg cmd quit

    # let go of session
    case $1 in
	    quit) bspc quit;;
    esac
}

closeall_2bwm()
{
	for w in $(lsw|cut -d' ' -f1); do
		xdo kill "$w"
	done

	while [ "$(lsw|wc -l)" -gt 0 ]; do
		sleep 1
	done 

	case $1 in
		quit) pkill 2bwm
	esac
}

closeall_i3()
{
	# Kindly close all regular windows
	i3-msg '[class=.*] kill'
	# wait until closed
	while [ "$(i3-msg -t get_tree|jq 'recurse(.nodes[]) | select(.window_type=="normal").window'|wc -l)" -gt 0 ];
	do
		sleep 1
	done
	for d in "$XDG_RUNTIME_DIR"/i3/*.pid; do
		read -r pid < "$d"
		kill "$pid"
		rm "$pid"
	done

    # let go of session
    case $1 in
	    quit) i3-msg exit;;
    esac
}

closeall_i3xfce()
{
	closeall_i3 "$1"
	closeall_xfce "$1"
	xfconf-query -c xfce4-session -p /general/SessionName -s Default
}

closeall_sway()
{
	# Kindly close all regular windows
	swaymsg '[app_id=.*] kill'
	# wait until closed
	while [ "$(swaymsg -t get_tree|grep -ce 'type.*con')" -gt 0 ];
	do
		sleep 1
	done
	# let go of session
	case $1 in
		quit) swaymsg exit;;
	esac
}

closeall_labwc()
{
	# let go of session
	case $1 in
		quit) labwc -e;;
	esac
}

closeall_hikari()
{
	# dont know yet
	pkill hikari
}

closeall_xfce()
{
	case $1 in
		quit) xfce4-session-logout -lf;;
	esac
}

closeall_startxfce4()
{
	closeall_xfce "$*"
}

closeall_gnome()
{
	case $1 in
		quit) gnome-session-quit --logout;;
	esac
}

closeall()
{
	fix_desktop
	closeall_common
	"closeall_${DESKTOP_SESSION}" "$*" || true
}

# requires an efi where each kernel is booted directly
ask_boot()
{
	sudo efibootmgr | grep Boot0 | sed 's/ /\t/g' | cut -f2 | ask 'boot:' || die ask_boot
}

boot()
{
	res=$(ask_boot)
	next=$(efibootmgr|grep "$res"|cut -c5-8)
	sudo efibootmgr -n "$next" || die boot "$next"
	closeall "$ctl" reboot
}

reload_bspwm()
{
	polybar-msg cmd restart
	#pkill -USR1 -F ~/.cache/bspwm/sxhkd.pid
	#did not work since pid is prefork
	pkill -USR1 sxhkdDP-3

	killall -sSIGHUP xsettingsd

    #bspc wm reload
    #to do
}

reload_sway()
{
	swaymsg reload
}

reload()
{
	fix_desktop
	"reload_${DESKTOP_SESSION}" || die reload
}

ask_sys()
{
	echo "$prompt"|tr " " "\n"|ask "sys:"|| true
}

lock_i3()
{
	for d in i3lock-fancy i3lock xflock4; do
		if command -v $d > /dev/null; then
			$d 
			return
		fi
	done
}

lock_sway()
{
	~/.config/sway/swaylock-fancy.sh "$PRIMARY"
}

lock()
{
	"lock_$DESKTOP_SESSION" || dm-tool lock
}

# determine init system
res=$(ask_sys)
read -r r < /proc/1/comm
case $r in
	systemd)    ctl=systemctl;; # insane
	*)          if type loginctl>/dev/null 2>&1; then
		ctl=loginctl  # sane
	else
		ctl=sudo      # seatd
		fi;;
esac

echo "dmenu-sys.sh: ${res}@${ctl}"

case $res in
	logout)             closeall quit;;
	reboot|poweroff)    closeall && $ctl "$res";;
	single|dual)        randr "$res";;
	lock)               lock;;
	sleep)              $ctl suspend;;
	reload)             reload;;
	boot)               boot && $ctl reboot;;
esac
