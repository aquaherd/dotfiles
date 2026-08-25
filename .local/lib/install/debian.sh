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

# Debian packages fd-find under the binary name `fdfind`; expose `fd`.
if ! has fd && has fdfind; then
  log "linking fdfind -> fd"
  as_root mkdir -p /usr/local/bin
  as_root ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

install_neovim_tarball
log "debian flavor complete"
