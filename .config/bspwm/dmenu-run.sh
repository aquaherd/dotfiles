#/bin/sh

#dmenu_path | dmenu -i $DMENU_DEFAULTS | ${SHELL:-"/bin/sh"} &
res=$(cut -f1 ~/.cache/applications | sort -u  | dmenu -i $DMENU_DEFAULTS) || exit 0
desktop=$(basename $(grep "$res" ~/.cache/applications | cut -f3))
echo "dmenu-run.sh: $desktop"
err=$(grep "$res" ~/.cache/applications | head -n1 | cut -f3 |  ${SHELL:-"/bin/sh"} 2>&1 )
fail=$?
if [ $fail -ne 0 ]; then
    zenity --error --text "error $fail: $err"
fi

