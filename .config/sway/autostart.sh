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
if [ -n "$DSIPLAY" ]; then
	start xsettingsd
	start_oneshot xrdb -merge ~/.Xresources
fi

# alpine linux specials
if [ -x /usr/libexec/pipewire-launcher ]; then
	/usr/libexec/pipewire-launcher
fi

# policy kit, if exists
if [ -x /usr/local/libexec/xfce-polkit ]; then
	/usr/local/libexec/xfce-polkit &
fi
