#!/bin/sh
# Optional "heavier" installs. Run via: bootstrap --with-extra
# Extend per-flavor cases below; keep everything idempotent.
set -eu
. "$(dirname "$0")/common.sh"

detect_sudo
FLAVOR="${FLAVOR:-unknown}"

# Refresh the user font cache so the tracked Nerd Fonts in ~/.local/share/fonts
# are picked up. Harmless and idempotent.
if [ -d "$HOME/.local/share/fonts" ] && has fc-cache; then
  log "refreshing font cache"
  fc-cache -f "$HOME/.local/share/fonts" || true
fi

# --- add heavier packages per flavor below ---------------------------------
case "$FLAVOR" in
  debian)
    # as_root apt-get install -y build-essential clang cmake ninja-build
    ;;
  alpine)
    # as_root apk add --no-cache build-base clang cmake samurai
    ;;
  macos-macports)
    # as_root port -N install clang-17 cmake ninja
    ;;
esac

log "extra tier complete"
