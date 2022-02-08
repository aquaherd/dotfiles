#/bin/sh
. ~/.profile

xrdb -merge ~/.Xresources
update-hsetroot.sh
sxhkd -c ~/.local/share/dwm/sxhkd.conf &
st &
xsettingsd&


