if [ "$SSH_AUTH_SOCK" = "" ]; then
	export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.sock"
fi
if [ ! -S "$SSH_AUTH_SOCK" ] || ! ssh-add -l > /dev/null 2>&1; then
	eval $(ssh-agent -a "$SSH_AUTH_SOCK")
fi
