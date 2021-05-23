#/bin/sh
if xrandr | grep -qe " connected [0-9]"; then
    nitrogen --random --set-zoom-fill --head=-1 ~/Pictures/Backdrops/dual/
else
    nitrogen --random --set-zoom-fill ~/Pictures/Backdrops/ghibli/
fi
