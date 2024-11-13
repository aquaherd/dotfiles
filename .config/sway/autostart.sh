#!/bin/bash 
PATH+=:~/.local/bin
# shellcheck source=../../.local/lib/dmenu-lib.sh
. ~/.local/lib/dmenu-lib.sh
autostart_common

# code, etc
export ELECTRON_OZONE_PLATFORM_HINT=auto
export MOZ_ENABLE_WAYLAND=1

# themes
gset gtk-theme 'Dracula'
gset icon-theme 'Dracula'
gset font-name 'Liberation Sans Narow 13'
gset cursor-theme 'Adwaita'

# start i3-autotiling
LANG=C.UTF-8 start foot --server
start gammastep-indicator
start mako 

# X11
start xsettingsd
start_oneshot xrdb -merge ~/.Xresources
