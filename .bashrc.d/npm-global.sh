# npm global bin on PATH.
# The npm prefix is set in ~/.npmrc, so global installs land here.
if [ -d "$HOME/.openchamber/npm-global/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.openchamber/npm-global/bin:"*) ;;
    *) export PATH="$HOME/.openchamber/npm-global/bin:$PATH" ;;
  esac
fi
