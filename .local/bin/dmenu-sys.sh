#/bin/sh

prompt="logout reboot poweroff lock sleep single dual boot reload"
dmenu="dmenu -i -p sys $DMENU_DEFAULTS"

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
        kill $pid || pkill $cmd || pkill $cmd -9 || zenity --error --text "could not kill $pid:$cmd"
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

closeall_xfce()
{
    case $1 in
    quit) xfce4-session-logout -lf;;
    esac
}

closeall()
{
    closeall_${DESKTOP_SESSION} $* || die
}

randr_bspwm()
{
    .config/bspwm/xrandr.sh $res
}

randr()
{
    randr_${DESKTOP_SESSION} $* || die
}

# requires an efi where each kernel is booted directly
ask_boot()
{
    efibootmgr | grep Boot0 | cut -d' ' -f2- | dmenu -i -p 'boot:' $DMENU_DEFAULTS || die
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

ask_sys()
{
    echo $prompt|tr " " "\n"|dmenu -i -p 'sys:' $DMENU_DEFAULTS || die
}

# determine init system
res=$(ask_sys)
read r < /proc/1/comm
case $r in
systemd)    ctl=systemctl;; # insane
*)          ctl=loginctl;;  # sane
esac

echo "dmenu-sys.sh: ${res}@${ctl}"

case $res in
    logout)             closeall quit;;
    reboot|poweroff)    closeall && $ctl $res;;
    single|dual)        randr $res;;
    lock)               dm-tool lock;;
    sleep)              $ctl suspend;;
    reload)             reload_${DESKTOP_SESSION};;
    boot)               boot && $ctl reboot;;
esac

