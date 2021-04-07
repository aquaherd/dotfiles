#!/bin/sh
# update the application cache for use with dmenu

usr=/usr/share/applications
loc=~/.local/share/applications
self=~/.config/bspwm/update-appcache.sh
cache=~/.cache/bspwm/applications

if [ $# -eq 0 ];then
    if [ $cache -nt $usr -a $cache -nt $loc ]; then
        echo app cache is up to date.
        exit 0
    fi
    rm -rf ${cache}.new # just in case
    find $usr $loc -type f -name '*.desktop' -exec $0 {} \; # call self with arg
    mv -vf ${cache}.new ${cache} # atomic
else
    f=$*
    if [ -z "$f" -o ! -f "$f" ] || grep -q '^OnlyShowIn=\|^DontShowIn=\|^NoDisplay=true' "$f"; then 
        echo skip: $f
        exit 0
    fi
    name=$(grep ^Name= "$f" | head -n1 | cut -b6-)
    if [ -n "$name" ]; then
        echo -n "${name}\t${f}\t" >> ${cache}.new
        grep ^Exec= "$f" | head -n1 | cut -b6- >> $cache.new || echo broken: $name: $f
        echo add: $name $f
    fi
fi

