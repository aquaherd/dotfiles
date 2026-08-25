# acme.sh shell environment (per-machine; sourced only when present)
if [ -r "$HOME/.acme.sh/acme.sh.env" ]; then
  . "$HOME/.acme.sh/acme.sh.env"
fi
