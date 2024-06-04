#!/bin/sh

apply()
{
	hsetroot -root -cover "$1" > /dev/null 2>&1 || hsetroot -cover "$1" > /dev/null 2>&1
	exit 0
}

usage()
{
	echo "$*" \
		"Usage: update-hsetroot [OPTIONS]
			updates backdrop in a dual/single monitor aware way.

			Options:
			-r,--restore:	restore previous
			-h,--help:	this help
			-s,--shuffle:	random shuffle
			"
			exit 1

		}

		mode()
		{
			m=dual
			if [ 1 -eq "$(xrandr --listactivemonitors | grep Monitors | cut -d' ' -f2)" ]; then
				m=single
			else
				m=dual
			fi
			echo $m
		}

		shuffle()
		{
			m=$(mode)
			DIR=~/Pictures/Backdrops/${m}
			DST=~/.cache/i3.current.backdrop
			CUR=$(readlink "$DST" || echo none)
			SET="$CUR"
			while [ "$CUR" = "$SET" ]; do
				SET=$(shuf -n1 -e "$DIR"/*)
			done
			echo "$CUR $SET $DST"
			ln -svf "$SET" "$DST"
			cp -v "$SET" "/usr/local/share/backgrounds/$(id -un)" 
			echo "$m" > "${DST}.mode"
			apply "$DST" 
		}

		restore()
		{
			DST=/usr/local/share/backgrounds/$(id -un)
			modeNew="$(mode)"
			read -r modeOld < ~/.cache/i3.current.backdrop.mode 
			if [  ! -f "$DST" ]; then
				echo "$DST not found. Shuffle."
				shuffle
			fi
			if [ "$modeNew" != "$modeOld" ]; then
				echo "mode not found. Shuffle."
				shuffle
			fi
			apply "$DST"
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
		shuffle
