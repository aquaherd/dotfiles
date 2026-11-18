#!/bin/sh
# Alpine Linux flavor (apk). Neovim uses the packaged version.
set -eu
. "$(dirname "$0")/common.sh"

detect_sudo

# neovim/ripgrep/fzf/fd/zoxide live in the community repo; refresh indexes first.
log "refreshing apk indexes"
as_root apk update

log "installing neovim, ripgrep, fzf, fd, zoxide via apk"
as_root apk add --no-cache neovim ripgrep fzf fd zoxide

case "${DESKTOP:-}" in
  sway)
    log "installing Sway desktop packages"
    as_root apk add --no-cache \
      sway swayidle swaylock xwayland grim slurp jq imagemagick fontconfig \
      foot firefox thunar fuzzel i3status mako wayvnc seatd \
      dbus glib gsettings-desktop-schemas gtk+3.0 libnotify zenity \
      mpd mpc playerctl pamixer
    warn "Alpine does not package gammastep-indicator or Hamster; those optional features will be unavailable"
    ;;
  i3)
    log "installing i3 desktop packages"
    as_root apk add --no-cache \
      i3wm i3status i3lock xorg-server xinit xrandr xsetroot xrdb \
      xsettingsd wmname dmenu st rofi thunar firefox picom dunst redshift \
      scrot xfce4-screenshooter imagemagick fontconfig \
      dbus glib gsettings-desktop-schemas gtk+3.0 libnotify zenity \
      mpd mpc playerctl alsa-utils
    warn "Alpine does not package Hamster, hsetroot, pqiv, or i3-autotiling; those optional features will be unavailable"
    ;;
esac

log "alpine flavor complete"
