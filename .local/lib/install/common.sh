#!/bin/sh
# Shared helpers for dotfiles install sub-scripts under .local/lib/install.
# Each flavor script sources this via: . "$(dirname "$0")/common.sh"

log()  { printf '%s\n' "==> $*"; }
warn() { printf '%s\n' "!! $*" >&2; }
die()  { printf '%s\n' "xx $*" >&2; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

# Detect a privilege-escalation command (prefer doas on Alpine, else sudo).
SUDO=""
detect_sudo() {
  [ -n "$SUDO" ] && return 0
  for s in doas sudo; do
    if has "$s"; then
      SUDO="$s"
      export SUDO
      return 0
    fi
  done
  warn "neither doas nor sudo found; assuming root or a sudo-less setup"
  SUDO=""
}

# Run a command as root when needed (no-op when already root).
as_root() {
  if [ "$(id -u)" -eq 0 ] || [ -z "$SUDO" ]; then
    "$@"
  else
    "$SUDO" "$@"
  fi
}

# Install the latest stable Neovim from the official GitHub release tarball
# into ~/.local/opt/nvim, with ~/.local/bin/nvim symlinked. Idempotent.
install_neovim_tarball() {
  local os arch name url tmp src dest bindir
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os/$arch" in
    Linux/x86_64|Linux/amd64) name="nvim-linux-x86_64.tar.gz" ;;
    Linux/arm64|Linux/aarch64) name="nvim-linux-arm64.tar.gz" ;;
    Darwin/x86_64)             name="nvim-macos-x86_64.tar.gz" ;;
    Darwin/arm64)              name="nvim-macos-arm64.tar.gz" ;;
    *) die "no prebuilt Neovim tarball for $os/$arch" ;;
  esac

  url="https://github.com/neovim/neovim/releases/latest/download/$name"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT

  log "downloading Neovim ($name)"
  curl -fsSL --retry 3 -o "$tmp/$name" "$url" || die "download failed: $url"

  log "extracting Neovim"
  tar -xzf "$tmp/$name" -C "$tmp"
  src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  [ -n "$src" ] && [ -x "$src/bin/nvim" ] || die "unexpected tarball layout (missing bin/nvim)"

  dest="$HOME/.local/opt/nvim"
  bindir="$HOME/.local/bin"
  mkdir -p "$HOME/.local/opt" "$bindir"
  rm -rf "$dest"
  mv "$src" "$dest"
  ln -sfn "$dest/bin/nvim" "$bindir/nvim"
  log "installed $dest/bin/nvim -> $bindir/nvim"
}
