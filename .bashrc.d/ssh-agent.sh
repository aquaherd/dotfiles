if [ "$SSH_AUTH_SOCK" = "" ]; then
	export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/openssh_agent"
fi
