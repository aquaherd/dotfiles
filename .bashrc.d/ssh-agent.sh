if [ "$SSH_AUTH_SOCK" = "" ]; then
	export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.sock"
fi
if [ ! -S "$SSH_AUTH_SOCK" ]; then
	eval $(ssh-agent -a "$SSH_AUTH_SOCK" &>/dev/null )
	trap "ssh-agent -k" exit
fi

ssh-add -l &>/dev/null

case $? in
	2)eval $(ssh-agent -a "$SSH_AUTH_SOCK" &>/dev/null);;
	1)ssh-add &>/dev/null;;
	0);;
esac
