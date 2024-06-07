#!/bin/sh

img=$(find ~/Pictures/Backdrops/space  -type f | sort --random-sort | head -n1)
echo "bgrot.sh: $img"
ln -sf "$img" ~/.cache/swaybg
swaymsg output '*' bg ~/.cache/swaybg fill
