#!/bin/sh

case $1 in
single)
    xrandr --output DisplayPort-1 --off --output DisplayPort-2 --off --output DisplayPort-0 --primary --auto --output HDMI-A-0 --off
    bspc monitor $PRIMARY -d aud vid sys log wrk web com rem
    ;;
dual)
    xrandr --output DisplayPort-1 --off --output DisplayPort-2 --off --output DisplayPort-0 --primary --auto --output $PRIMARY --auto --right-of $SECONDARY
    bspc monitor $PRIMARY -d wrk web com rem
    bspc monitor $SECONDARY -d aud vid sys log
    ;;
esac

~/.config/bspwm/polybar.sh $1
