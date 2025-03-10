#!/bin/bash
# shellcheck source=../lib/dmenu-lib.sh
. ~/.local/lib/dmenu-lib.sh
res=$(cut -f1 ~/.cache/applications.txt | sort -u  | ask 'drun:') || exit 0
path=$(grep "$res"$'\t' ~/.cache/applications.txt | cut -f2)
desktop=$(basename "$path")
echo "dmenu-run.sh: $res -> $desktop"
gtk-launch "$desktop"
fail=$?
if [ $fail -ne 0 ]; then
    zenity --error --text "error $fail: $desktop"
fi

