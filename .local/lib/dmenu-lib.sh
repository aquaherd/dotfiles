# this is a posix shell fragment for inclusion not execution

fix_desktop() # in case you start without display manager
{
	if [ -z "$DESKTOP_SESSION" ]; then
		if [ -n "$SWAYSOCK" ]; then
			export DESKTOP_SESSION=sway
			return
		elif [ -n "$I3SOCK" ]; then
			export DESKTOP_SESSION=i3
			return
		fi
	fi
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
        dmenu-wl -i -p $1 -fn 'Iosevka Term 15' -nb '#44475a' -sb '#bd93f9' -h 30 -m $m -b
        ;;
    hikari)
        # dont know how to determine current monitor in hikari
        dmenu-wl -i -p $1 -fn 'Iosevka Term 15' -nb '#44475a' -sb '#bd93f9' -h 30 -b
        ;;
    *)
        : ${DMENU_DEFAULTS:='-fn sans:fontformat=truetype:pixelsize=20 -nb #44475a -sb #bd93f9'}
        dmenu -i -p $1 $DMENU_DEFAULTS
        ;;
    esac
}
