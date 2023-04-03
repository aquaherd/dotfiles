#!/bin/sh

img=$(find ~/Pictures/Backdrops  -type f | sort --random-sort | head -n1)
echo "bgrot.sh: $img"
swaymsg output '*' bg $img fill
