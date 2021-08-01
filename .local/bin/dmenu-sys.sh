#/bin/sh
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
        bspc node $d -c
    done
    while [ $(bspc query -N|wc -l) -gt 0 ]; do
        sleep 1
    done

    # from bspwmrc
    for f in ~/.cache/bspwm/*.pid; do
        local cmd=$(basename -s .pid $f)
        read pid < $f
        kill $pid || pkill $cmd || pkill $cmd -9 || true
        rm $f
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
        xdo kill $w
    done

    while [ $(lsw|wc -l) -gt 0 ]; do
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
    while [ $(i3-msg -t get_tree|jq 'recurse(.nodes[]) | select(.window_type=="normal").window'|wc -l) -gt 0 ];
    do
        sleep 1
    done
    # let go of session
    case $1 in
    quit) i3-msg exit;;
    esac
}

closeall_sway()
{
    # Kindly close all regular windows
    swaymsg '[app_id=.*] kill'
    # wait until closed
    while [ $(swaymsg -t get_tree|grep -ce 'type.*con') -gt 0 ];
    do
        sleep 1
    done
    # let go of session
    case $1 in
    quit) swaymsg exit;;
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
    closeall_xfce $*
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
    closeall_${DESKTOP_SESSION} $* || true
}

randr_bspwm()
{
    .config/bspwm/xrandr.sh $res
}

randr_default()
{
    case $1 in
    single)
        xrandr \
            --output $PRIMARY --primary --auto \
            --output $SECONDARY --off
        ;;
    dual)
        xrandr \
            --output $PRIMARY --primary --auto \
            --output $SECONDARY --auto --left-of $PRIMARY
        ;;
    esac
}

randr()
{
    fix_desktop
    echo "randr: $PRIMARY $SECONDARY randr_${DESKTOP_SESSION}  $*"
    randr_${DESKTOP_SESSION} $* || randr_default $*
}

# requires an efi where each kernel is booted directly
ask_boot()
{
    sudo efibootmgr | grep Boot0 | cut -d' ' -f2- | ask 'boot:' || die ask_boot
}

boot()
{
    res=$(ask_boot)
    next=$(efibootmgr|grep $res|cut -c5-8)
    sudo efibootmgr -n $next
    closeall $ctl reboot
}

reload_bspwm()
{
    polybar-msg cmd restart
    #pkill -USR1 -F ~/.cache/bspwm/sxhkd.pid
    #did not work since pid is prefork
    pkill -USR1 sxhkd

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
	reload_${DESKTOP_SESSION} $* || die reload $*
}

ask_sys()
{
    echo $prompt|tr " " "\n"|ask "sys:"|| true
}

# determine init system
res=$(ask_sys)
read r < /proc/1/comm
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
    reboot|poweroff)    closeall && $ctl $res;;
    single|dual)        randr $res;;
    lock)               dm-tool lock;;
    sleep)              $ctl suspend;;
    reload)             reload;;
    boot)               boot && $ctl reboot;;
esac
