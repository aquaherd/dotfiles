#!/bin/sh
# update the application cache for use with dmenu

usr=/usr/share/applications
loc=~/.local/share/applications
fpk=~/.local/share/flatpak/exports/share/applications
cache=~/.cache/applications.txt

if [ $# -eq 0 ];then
    if [ $cache -nt $usr -a $cache -nt $loc -a $cache -nt $fpk ]; then
        echo app cache is up to date.
        exit 0
    fi
    rm -rf ${cache}.new # just in case
    find $usr $loc $fpk -name '*.desktop' -exec $0 {} \; # call self with arg
    mv -vf ${cache}.new ${cache} # atomic
else
    f=$*
    if [ -z "$f" -o ! -f "$f" ] || grep -q '^OnlyShowIn=\|^DontShowIn=\|^NoDisplay=true' "$f"; then 
        echo skip: $f
        exit 0
    fi
    name=$(grep ^Name= "$f" | head -n1 | cut -b6-)
    if [ -n "$name" ]; then
        printf '%s\t%s\n' "${name}" "${f}" >> ${cache}.new
        echo add: $name $f
    fi
fi

