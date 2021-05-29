#!/bin/sh
# run minimum needful things before starting the WM
# see ~/.local/bin.startX

test -f ~/.Xresources && xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr

exec $1
