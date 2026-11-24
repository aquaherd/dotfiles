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
	for f in ~/.cache/bspwm	/*.pid; do
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
# selectable boot targets: "name\tbootnum" (internal; num is "-" for setup)
boot_entries()
{
	{
	sudo efibootmgr | while IFS= read -r line; do
		case $line in
			Boot0*) : ;;
			*) continue ;;
		esac
		num=$(printf '%s\n' "$line" | sed -n 's/^Boot\([0-9A-F]\{4\}\).*/\1/p')
		# firmware shows all distro entries with the same label, so derive
		# the name from the loader path instead: \EFI\<ID>\loader.efi for
		# vendor chains, \EFI\Linux\<ID>.efi for efistub UKIs. The firmware
		# may print paths in upper or lower case, so parse the lowercased
		# line: "debian uki", "alpine grub", "setup", ...
		lc=$(printf '%s\n' "$line" | tr 'A-Z' 'a-z')
		fpath=$(printf '%s\n' "$lc" |
			sed -n 's/.*file(\\efi\\\([^\\]*\)\\\([^)]*\)).*/\1|\2/p')
		if [ -n "$fpath" ]; then
			dir=${fpath%%|*}
			file=${fpath#*|}
			base=$(printf '%s\n' "$file" | sed 's/.*\\//; s/\.efi$//')
			case $dir in
				linux)	name="$base uki";;
				boot)	name="fallback $base";;
				*)	case $file in
						grubx64.efi)	name="$dir grub";;
						shimx64.efi)	name="$dir shim (secure boot)";;
						mmx64.efi)	name="$dir mok";;
						*)		name="$dir $base";;
					esac;;
			esac
		else
			name=$(printf '%s\n' "$line" |
				sed -n 's/^Boot[0-9A-F]\{4\}\*//p' | cut -f1 | sed 's/^[[:space:]]*//')
		fi
		printf '%s\t%s\n' "$name" "$num"
	done
	printf '%s\t%s\n' setup -
	}
}

# dmenu items are the bare names; the tab-separated boot number never
# reaches the UI (dmenu renders tabs as garbage glyphs)
ask_boot()
{
	boot_entries | cut -f1 | sort | ask 'boot:' || die ask_boot
}

boot()
{
	res=$(ask_boot) || return
	case $res in
		setup*)	setup;;
		*)
			next=$(boot_entries | awk -F'\t' -v n="$res" '$1 == n {print $2}')
			[ -n "$next" ] || die boot 'no entry selected'
			sudo efibootmgr -n "$next" || die boot "$next"
			closeall "$ctl" reboot;;
	esac
}

# enter UEFI setup on next boot (writes the OsIndications EFI variable;
# this Insyde/ASRock firmware honours it even though it does not
# advertise the OsIndicationsSupported flag). Falls back to a hint if
# systemd/logind refuses (e.g. support disabled in firmware).
setup()
{
	if ! sudo systemctl reboot --firmware-setup; then
		notify-send -i error 'Firmware does not support reboot-to-setup — press DEL during POST'
	fi
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
	fix_desktop
	"lock_$DESKTOP_SESSION" || dm-tool lock
}

# determine init system
res=$(ask_sys)
read -r r < /proc/1/comm
case $r in
	systemd) ctl=systemctl;; # insane
	*) if type loginctl>/dev/null 2>&1; then
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
