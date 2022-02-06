#!/bin/sh

DIR=~/Pictures/Backdrops/dual
DST=~/.cache/i3.current.backdrop
CUR=$(readlink "$DST" || echo none)
SET="$CUR"
while [ "$CUR" = "$SET" ]; do
	SET=$(shuf -n1 -e "$DIR"/*)
done

ln -svf "$SET" "$DST"
hsetroot -root -cover $DST > /dev/null 2>&1 || hsetroot -cover $DST > /dev/null 2>&1
