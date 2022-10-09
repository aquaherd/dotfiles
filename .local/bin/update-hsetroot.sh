#!/bin/sh
read m < /var/run/user/$(id -u)/dmenu-mode
DIR=~/Pictures/Backdrops/${m}
DST=~/.cache/i3.current.backdrop
CUR=$(readlink "$DST" || echo none)
SET="$CUR"
while [ "$CUR" = "$SET" ]; do
	SET=$(shuf -n1 -e "$DIR"/*)
done
echo $CUR $SET $DST
ln -svf "$SET" "$DST"
hsetroot -root -cover $DST > /dev/null 2>&1 || hsetroot -cover $DST > /dev/null 2>&1
