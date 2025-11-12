#!/bin/sh
set -eu

echo "...Updating Nix channels..."
nix-channel --update

echo "...Evaluating current and next system..."
current=$(readlink -f /run/current-system)
next_drv=$(nix-instantiate '<nixpkgs/nixos>' -A system 2>/dev/null)

# Realize the drv to get the final store path
next=$(nix-store -r "$next_drv" 2>/dev/null)

if [ "$current" = "$next" ]; then
    echo "✅ System already up to date: $current"
else
    echo "🔄 New system detected:"
    echo "   current → $current"
    echo "   next    → $next"
    echo "⚙️  Rebuilding..."
    nixos-rebuild switch
    echo "🧹 Cleaning old generations..."
    nix-collect-garbage --delete-older-than 2d
fi

echo "✨ Done."
