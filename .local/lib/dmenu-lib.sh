# this is a posix shell fragment for inclusion not execution

fix_desktop() # in case you start without display manager
{
    if [ -z "$DESKTOP_SESSION" ]; then
        if [ -n "$SWAYSOCK" ]; then
            export DESKTOP_SESSION=sway
        elif [ -n "$I3SOCK" ]; then
            export DESKTOP_SESSION=i3
        elif [ -z "$DISPLAY"  ]; then
            export DESKTOP_SESSION=none
            return
        else
            DESKTOP_SESSION="$(wmname)"
            export DESKTOP_SESSION
        fi
    fi

    if [ -z "$WAYLAND_DISPLAY" ]; then
        #x11
        if [ -z "$PRIMARY" ]; then
            if [ "$(xrdb -q|wc -l)" -eq 0 ]; then
                xrdb -merge ~/.Xresources
            fi

            PRIMARY=$(xrdb -q | grep Xdisplay.primary | cut -f2)
            SECONDARY=$(xrdb -q | grep Xdisplay.secondary | cut -f2)
            export PRIMARY SECONDARY
        fi
    fi

}

DST=/usr/local/share/backgrounds/$(id -un)
restore_backdrop_x11()
{
    if [  ! -f "$DST" ]; then
        echo "$DST not found. Shuffle."
        update-hsetroot.sh
    else
        hsetroot -root -cover "$DST" > /dev/null 2>&1 || hsetroot -cover "$DST" > /dev/null 2>&1
    fi 
}
restore_backdrop()
{
    fix_desktop
    case $DESKTOP_SESSION in
        i3|2bwm|progman) restore_backdrop_x11;return 0;;
        *) return 1;;
    esac
}
ask() # bifurcate to dmenu or dmenu-wl
{
    fix_desktop
    case $DESKTOP_SESSION in
        sway)
            m=0
            # dmenu-wl does not use current focused monitor as dmenu-x11 does
            for p in $(swaymsg -t get_outputs | jq -r '.[] ' | jq -r '.focused'); do
                if $p; then
                    break
                fi
                m=$((1+m))
            done
            dmenu-wl -i -p "$1" -fn 'Iosevka 15' -nb '#44475a' -sb '#bd93f9' -h 30 -m $m -b
            ;;
        hikari|wayfire)
            # dont know how to determine current monitor in hikari
            dmenu-wl -i -p "$1" -fn 'Iosevka 15' -nb '#44475a' -sb '#bd93f9' -h 30 -b
            ;;
        gnome)
            if [ -n "$WAYLAND_DISPLAY" ]; then
                wofi -p "$1" -S dmenu
            else
                dmenu -i -p "$1"
            fi
            ;;
        none)
            fzf
            ;;
        *)
            dmenu -b -i -p "$1"
            ;;
    esac
}
