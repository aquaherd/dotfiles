#!/bin/sh
SAV=~/.cache/update-hsetroot-backdrop
USR="/usr/local/share/backgrounds/$(id -un)" 

swaysplit()
{
	cp -f $SAV $SAV.left
	cp -f $SAV $SAV.right
	read -r width height
	half=$((width/2))
	mogrify -crop "${half}x${height}+0+0" $SAV.left
	mogrify -crop "${half}x${height}+${half}+0" $SAV.right
}

apply()
{
	f=$(readlink "$1")
	echo "applying mode $m $f $XDG_SESSION_DESKTOP"
	case "$XDG_SESSION_TYPE" in
		wayland)
			case "$XDG_SESSION_DESKTOP" in
				sway)
					if [ "$m" = "dual" ]; then
						identify "$SAV" | cut -d' ' -f3 | tr 'x' ' ' | swaysplit
						swaymsg output \$primary bg "$1.right" fill
						swaymsg output \$secondary bg "$1.left" fill
						exit 0
					fi
					swaymsg output '*' bg "$1" fill
					;;
				*) swww img "$1";;
			esac;;
		x11) hsetroot -root -cover "$1" > /dev/null 2>&1 || hsetroot -cover "$1" > /dev/null 2>&1;;
	esac
	exit 0
}

usage()
{
	cat <<- EOF
	Usage: update-hsetroot [OPTIONS]
	updates backdrop in a dual/single monitor aware way.

	Options:
	-r,--restore:	restore previous
	-h,--help:	this help
	-s,--shuffle:	random shuffle
	
	EOF
	exit 1
}

mode()
{
	m=single
	if [ -f ~/.cache/xrandr ]; then
		read -r m < ~/.cache/xrandr
	fi
	echo $m
}

shuffle()
{
	m=$(mode)
	DIR=~/Pictures/Backdrops/${m}
	CUR=$(readlink "$SAV" || echo none)
	SET="$CUR"
	while [ "$CUR" = "$SET" ]; do
		SET=$(shuf -n1 -e "$DIR"/*)
	done
	echo "$CUR $SET $SAV"
	ln -sf "$SET" "$SAV"
	cp "$SET" "$USR"
	echo "$m" > "${SAV}.mode"
	apply "$SAV" 
}

restore()
{
	read -r modeOld < $SAV.mode 
	m="$(mode)"
	if [  ! -f "$SAV" ]; then
		echo "$SAV not found. Shuffle."
		shuffle
	fi
	if [ "$m" != "$modeOld" ]; then
		echo "mode not found. Shuffle."
		shuffle
	fi
	apply "$SAV"
}

if ! GETOPT=$(getopt -o rhs --long restore,help,shuffle -n 'update-hsetroot.sh' -- "$@"); then
	usage
fi

eval set -- "$GETOPT"
while true; do
	case $1 in
		-r|--restore) restore;;
		-h|--help) usage;;
		-s|--shuffle) shuffle;;
		--) shift;break;;
		*) usage "$*";;
	esac
done
# default action
echo "$0: no argument given. Use -h for help"
