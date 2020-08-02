#!/bin/sh
# hamster output is like: 2020-06-27 15:14 Computing@FreeTime 00:28
# this script summarizes the current category
last="---"
while :; do
    
    hamster current | cut -d" " -f3 > ~/.cache/hamstermon
    IFS='@' read fact category < ~/.cache/hamstermon
    
    if [ -z "$fact" ]; then
        current=""
    elif [ -z "$category" ]; then
        current=" $fact"
    else
        hamster search $category|grep Total|cut -b 9- > ~/.cache/hamstermon
        read duration < ~/.cache/hamstermon
        
        if [ -z "$duration" ]; then
            current=" $category"
        else
            current=" $category: $duration"
        fi
    fi
    
    if [ "$last" != "$current" ]; then
        last="$current"
        echo $last
    fi
    
    inotifywait -qt 60 -e modify \
        ~/.local/share/hamster/hamster.db \
        2>&1 > /dev/null
done

