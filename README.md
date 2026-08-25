# dotfiles

Possibly not worth much, however an attempt at modularity and portability is made.

## bootstrap

`~/.local/bin/bootstrap` brings up these dotfiles on a fresh machine and installs
the base toolchain (latest stable Neovim, ripgrep, fzf, fd, zoxide). It is
idempotent and safe to re-run.

```sh
# From a clean checkout of this repo (recommended):
/path/to/checkout/.local/bin/bootstrap --source /path/to/checkout

# Re-run installs on an already-bootstrapped machine:
~/.local/bin/bootstrap [--with-extra]

# Fresh machine with no checkout yet (fetches the bootstrap, clones + checks out):
curl -fsSL https://raw.githubusercontent.com/aquaherd/dotfiles/master/.local/bin/bootstrap -o /tmp/bootstrap \
  && sh /tmp/bootstrap
```

Options: `--skip-clone`, `--skip-checkout`, `--with-extra`, `--flavor NAME`,
`--remote URL`, `--source DIR`, `--list-flavors` (see `bootstrap --help`).

### Sub-flavors

OS-specific install logic lives in `.local/lib/install/<flavor>.sh`, with shared
helpers in `common.sh` and an optional `extra.sh` tier. Add a new OS by dropping a
new `<flavor>.sh` there.

| flavor           | package manager | Neovim source                |
|------------------|-----------------|------------------------------|
| `debian`         | apt             | official prebuilt tarball    |
| `alpine`         | apk             | packaged                     |
| `macos-macports` | MacPorts        | packaged (`port install`)    |

The repo is a bare-repo dotfiles layout: git dir at `~/.cfg`, work-tree `~`, alias
`cfg='git --git-dir=$HOME/.cfg --work-tree=$HOME'` (see `.bashrc.d/shared-aliases.sh`).
`.gitignore` is `*`, so new tracked files are added with `git add -f`.

## 2bwm
* minor patches

## awesome
* not tried yet

## bspwm
* unused desktop, highly customized
* modular, scripted

## dwm
* at stock

## i3
* workhorse
* high effort

## i3+xfce
* medium effort

## neovim
* daily driver
* tracking stable, single line config with LSP for c/c++

## progman
* no patches yet

## spectrwm
* not tried yet

## sway
* Under sync with i3
