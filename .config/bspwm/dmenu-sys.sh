#/bin/sh

prompt="logout reboot poweroff lock sleep single dual boot reload"
dmenu="dmenu -i -p sys $DMENU_DEFAULTS"

die ()
{
    kill $$
}

closeall()
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
        kill $pid || pkill $cmd || pkill $cmd -9 || echo "could not kill $pid:$cmd"
        rm $f
        echo "*** $pid:$cmd Ended ***"
    done
    
    # let go of panel last
    polybar-msg cmd quit
    
    # run logout/reboot/poweroff command
    $*
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

reload()
{
    polybar-msg cmd restart
    #pkill -USR1 -F ~/.cache/bspwm/sxhkd.pid
    #did not work since pid is prefork
    pkill -USR1 sxhkd
    
    killall -HUP xsettingsd
    
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
    logout)             closeall bspc quit;;
    reboot|poweroff)    closeall $ctl $res;;
    single|dual)        .config/bspwm/xrandr.sh $res;;
    lock)               dm-tool lock;;
    sleep)              $ctl suspend;;
    reload)             reload;;
    boot)               boot;;
esac


