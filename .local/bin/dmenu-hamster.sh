#!/bin/sh
# shellcheck source=../lib/dmenu-lib.sh
. ~/.local/lib/dmenu-lib.sh

verbatim='stop|overview|preferences|add|about'

die()
{
    kill $$
}

hamster_ask()
{
    echo "start|$verbatim"|tr "|" "\n"|ask 'hamster:' || die
} 

hamster_start()
{
    hamster activities|ask 'start:' || die
}

hamster_makeitso()
{
    if [ -n $1 ]; then
        if [ "$1" = "start" ]; then
            hamster add "$(hamster_start)"
        else
            hamster "$*" & 
        fi
    else
        echo "unknown selection: $*"
        return
    fi
}

hamster_usage()
{
    echo "usage: dmenu-hamster.sh ask|start|$verbatim"
}

hamster_dispatch()
{
    case $1 in
    ask) hamster_makeitso "$(hamster_ask)";;
    start) hamster add "$(hamster_start)";;
    stop|overview|preferences|add|about) hamster_makeitso "$1";;
    *) hamster_usage;;
    esac
}

hamster_dispatch "$1"
