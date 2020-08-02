#!/bin/sh

#IFS=':' 
#grep -rcv ^NoDisplay=true /usr/share/applications ~/.local/share/applications | while read f c; do
    #name=$(grep ^Name= $f | head -n1 | cut -b6-)
    #if [ -n "$name" ]; then
        #echo -n "${name}\t${f}\t" >> ~/.cache/applications
        #grep ^Exec= $f | cut -b6- >> ~/.cache/applications || echo $f is broken: $name
    #fi
#done

usr=/usr/share/applications
loc=~/.local/share/applications
self=~/.config/bspwm/update-appcache.sh
cache=~/.cache/applications

if [ $# -eq 0 ];then    
    rm -rf ~/.cache/applications
    find $usr $loc -type f -name '*.desktop' -exec $0 {} \;
else
    f=$*
    if [ -z "$f" -o ! -f "$f" ] || grep -q '^OnlyShowIn=\|^DontShowIn=' "$f"; then 
        echo skip: $f
        exit 0
    fi
    name=$(grep ^Name= "$f" | head -n1 | cut -b6-)
    if [ -n "$name" ]; then
        echo -n "${name}\t${f}\t" >> $cache
        grep ^Exec= "$f" | head -n1 | cut -b6- >> $cache || echo broken: $name: $f
        echo add: $name $f
    fi
fi

