#/bin/sh

#dmenu_path | dmenu -i $DMENU_DEFAULTS | ${SHELL:-"/bin/sh"} &
res=$(cut -f1 ~/.cache/bspwm/applications | sort -u  | dmenu -i $DMENU_DEFAULTS) || exit 0
desktop=$(basename $(grep "$res" ~/.cache/bspwm/applications | cut -f2))
echo "dmenu-run.sh: $desktop"
gtk-launch $desktop
fail=$?
if [ $fail -ne 0 ]; then
    zenity --error --text "error $fail: $err"
fi

