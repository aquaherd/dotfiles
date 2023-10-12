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
        elif [ -n "$WSL_DISTRO_NAME" ]; then
            if [ "$WSL2_GUI_APPS_ENABLED" = "1" ]; then
                export DESKTOP_SESSION=wslg
            else
                export DESKTOP_SESSION=none 
            fi
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

randr_bspwm()
{
    ~/.config/bspwm/xrandr.sh "$res"
}

randr_sway()
{
    case $1 in 
        single) swaymsg output \$secondary disable;;
        dual) swaymsg output \$secondary enable;;
    esac 
}

randr_default()
{
    case $1 in
    single)
        xrandr \
            --output "$PRIMARY" --primary --auto \
            --output "$SECONDARY" --off
        ;;
    dual)
        xrandr \
            --output "$PRIMARY" --primary --auto \
            --output "$SECONDARY" --auto --left-of "$PRIMARY"
        ;;
    esac
}

randr()
{
    fix_desktop
    read -r oldrandr < ~/.cache/xrandr
    echo "randr: $PRIMARY $SECONDARY randr_${DESKTOP_SESSION}  $*"
    "randr_${DESKTOP_SESSION}" "$*" || randr_default "$*"
    echo "$*" > .cache/xrandr
    if [ "$*" != "$oldrandr" ]; then
        update_backdrop || ~/.local/bin/update-hsetroot.sh
    fi

}

randr_restore()
{
    r="single"
    read -r r < ~/.cache/xrandr || true
    randr "$r"
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

ask()
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
        wslg)
            wofi -p "$1" -S dmenu 
            ;;
        *)
            dmenu -b -i -p "$1"
            ;;
    esac
}
