# Use the standalone CLI explicitly: on some machines /usr/bin/goose is the
# desktop app, which ignores CLI arguments and just opens its GUI.
if [ -x "$HOME/.local/bin/goose" ]; then
	source <("$HOME/.local/bin/goose" completion bash)
elif command -v goose > /dev/null; then
	source <(goose completion bash)
fi
