#!/bin/sh
# Debian / Ubuntu flavor (apt). Neovim uses the official prebuilt tarball.
set -eu
. "$(dirname "$0")/common.sh"

detect_sudo

log "updating package lists"
as_root apt-get update -y

log "installing ripgrep, fzf, fd-find, zoxide, and prerequisites"
as_root apt-get install -y \
  ripgrep fzf fd-find zoxide \
  curl ca-certificates

FIREFOX_PACKAGE=firefox-esr
if [ -r /etc/os-release ]; then
  . /etc/os-release
  case "${ID:-}" in
    ubuntu|pop|linuxmint) FIREFOX_PACKAGE=firefox ;;
  esac
fi

case "${DESKTOP:-}" in
  sway)
    log "installing Sway desktop packages"
    as_root apt-get install -y \
      sway swayidle swaylock xwayland grim slurp jq imagemagick fontconfig \
      foot "$FIREFOX_PACKAGE" thunar fuzzel i3status mako-notifier gammastep \
      dbus-user-session libnotify-bin libglib2.0-bin gsettings-desktop-schemas \
      libgtk-3-bin zenity hamster-time-tracker mpd mpc playerctl pamixer \
      wayvnc efibootmgr
    ;;
  i3)
    log "installing i3 desktop packages"
    as_root apt-get install -y \
      i3-wm i3status i3lock xserver-xorg xinit x11-xserver-utils x11-utils \
      dmenu rofi stterm thunar "$FIREFOX_PACKAGE" picom dunst xsettingsd wmname redshift \
      scrot pqiv xfce4-screenshooter hsetroot imagemagick fontconfig \
      libnotify-bin libglib2.0-bin gsettings-desktop-schemas libgtk-3-bin zenity \
      hamster-time-tracker mpd mpc playerctl alsa-utils efibootmgr
    ;;
esac

# Debian packages fd-find under the binary name `fdfind`; expose `fd`.
if ! has fd && has fdfind; then
  log "linking fdfind -> fd"
  as_root mkdir -p /usr/local/bin
  as_root ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

install_neovim_tarball
log "debian flavor complete"
