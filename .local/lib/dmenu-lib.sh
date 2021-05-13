# this is a posix shell fragment for inclusion not execution
ask()
{
    case $DESKTOP_SESSION in
    sway)
        m=0
        for p in $(swaymsg -t get_outputs | jq -r '.[] ' | jq -r '.focused'); do
            if $p; then
                break
            fi
            m=$((1+m))
        done
        dmenu-wl -i -p $1 -fn 'Cantarell 15' -nb '#44475a' -sb '#bd93f9' -h 30 -m $m
        ;;
    *)
        ${DMENU_DEFAULTS:='-fn sans:fontformat=truetype:pixelsize=20 -nb #44475a -sb #bd93f9'}
        dmenu -i -p $1 $DMENU_DEFAULTS
        ;;
    esac
}