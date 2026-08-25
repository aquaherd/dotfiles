# Ensure user-local bin directories are on PATH in every interactive shell.
# (~/.profile only does this for login shells, so non-login shells need it too.)
for d in "$HOME/.local/bin" "$HOME/bin"; do
  [ -d "$d" ] || continue
  case ":$PATH:" in
    *":$d:"*) ;;
    *) PATH="$d:$PATH"; export PATH ;;
  esac
done
