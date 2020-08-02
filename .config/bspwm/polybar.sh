#!/bin/sh

height_hide=0
height_show=26

border_hide=true
border_show=false

quit()
{
    pgrep polybar > /dev/null && polybar-msg cmd quit
}

save()
{
    echo $2 > ~/.cache/bspwm/polybar-$1
}

showhide()
{
    polybar-msg cmd $1
    save view $1
    view=height_$1
    border=border_$1
    bspc config top_padding $(eval echo \$$view)
    bspc config borderless_monocle $(eval echo \$$border)
}

case $1 in
dual|triple)
    quit
    polybar -r -c ~/.config/bspwm/polybar.conf primary 2>&1 &
    polybar -r -c ~/.config/bspwm/polybar.conf secondary 2>&1 &
    save mode $1
    save view show
    ;;

single)
    quit
    polybar -r -c ~/.config/bspwm/polybar.conf single 2>&1 &
    save mode $1
    save view show
    ;;

hide|show)
    showhide $1
    ;;

toggle)
    read view < ~/.cache/bspwm/polybar-view
    test $view = "hide" && view="show" || view="hide"
    showhide $view
    ;;

*)  echo 'usage: polybar.sh single|dual|triple|show|hide|toggle'
    ;;
esac
