#!/bin/sh

img=$(find ~/Pictures/Backdrops/space  -type f | sort --random-sort | head -n1)
echo "bgrot.sh: $img"
swaymsg output '*' bg $img fill
