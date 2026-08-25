#!/bin/sh
# macOS flavor via MacPorts (NOT Homebrew).
set -eu
. "$(dirname "$0")/common.sh"

has port || die "MacPorts 'port' not found; install it from https://www.macports.org/install.php"

detect_sudo

log "syncing MacPorts"
as_root port selfupdate

log "installing ripgrep, fzf, fd, zoxide, neovim via MacPorts"
as_root port -N install ripgrep fzf fd zoxide neovim
log "macos-macports flavor complete"
