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
log "alpine flavor complete"
