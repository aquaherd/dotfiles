#/bin/sh

xrdb -merge ~/.Xresources
update-hsetroot.sh
sxhkd -c ~/.local/share/dwm/sxhkd.conf &
xsettingsd&
picom&
slstatus&

