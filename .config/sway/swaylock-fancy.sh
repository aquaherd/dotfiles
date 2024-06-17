#!/bin/bash
# fancify later
FONT="$(convert -list font | awk "{ a[NR] = \$2 } /family: $(fc-match sans -f "%{family}\n")/ { print a[NR-1]; exit }")"
EFFECT=(-filter Gaussian -resize 20% -define filter:sigma=1.5 -resize 500.5%)
IMAGE=~/.cache/swaylock-fancy
grim -o DP-1 "$IMAGE"
convert "$IMAGE" "${EFFECT[@]}" -font "$FONT" -pointsize 250 -fill white -stroke lightgray -annotate +256+512 "Login:" "$IMAGE"
echo $PRIMARY $SECONDARY $MODE
exec swaylock -f -c 000000 -lki "$IMAGE"
