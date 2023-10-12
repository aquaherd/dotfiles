#/bin/sh
. ~/.local/lib/dmenu-lib.sh
#dmenu_path | dmenu -i $DMENU_DEFAULTS | ${SHELL:-"/bin/sh"} &
res=$(cut -f1 ~/.cache/applications.txt | sort -u  | ask 'drun:') || exit 0
desktop=$(basename $(grep -P "$res\t" ~/.cache/applications.txt | cut -f2))
echo "dmenu-run.sh: $res -> $desktop"
gtk-launch "$desktop"
fail=$?
if [ $fail -ne 0 ]; then
    zenity --error --text "error $fail: $desktop"
fi

