#!/bin/sh

case $1 in
single)
    xrandr \
        --output $PRIMARY --primary --auto \
        --output $SECONDARY --off
    bspc monitor $PRIMARY -d aud vid sys log wrk web com rem
    ;;
dual)
    xrandr \
        --output $PRIMARY --primary --auto \
        --output $SECONDARY --auto --left-of $PRIMARY
    bspc monitor $PRIMARY -d wrk web com rem
    bspc monitor $SECONDARY -d aud vid sys log
    ;;
esac

~/.config/bspwm/polybar.sh $1
