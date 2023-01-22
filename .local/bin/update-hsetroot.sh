#!/bin/sh
m=dual
if [ 1 -eq "$(xrandr --listactivemonitors | grep Monitors | cut -d' ' -f2)" ]; then
    m=single
else
    m=dual
fi
DIR=~/Pictures/Backdrops/${m}
DST=~/.cache/i3.current.backdrop
CUR=$(readlink "$DST" || echo none)
SET="$CUR"
while [ "$CUR" = "$SET" ]; do
    SET=$(shuf -n1 -e "$DIR"/*)
done
echo "$CUR $SET $DST"
ln -svf "$SET" "$DST"
hsetroot -root -cover $DST > /dev/null 2>&1 || hsetroot -cover $DST > /dev/null 2>&1
cp -v "$SET" "/usr/local/share/backgrounds/$(id -un)" 
