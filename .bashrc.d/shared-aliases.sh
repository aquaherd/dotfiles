#!/bin/bash
alias cdgr='cd $(git rev-parse --show-toplevel||echo .)'
alias cfg='git --git-dir=$HOME/.cfg --work-tree=$HOME '
alias curr='cat "$XDG_RUNTIME_DIR/host" 2> /dev/null || echo none'
alias quit='ssh -O exit '
alias drop='ssh-add -d - < ~/.ssh/encr.txt'
alias rnvim='nvim --remote-ui --server 127.0.0.1:8192 '

colors() {
	for i in {0..255}; do
		printf "\x1b[38;5;%sm%03d " "${i}" "${i}"
		if [ "15" = "$((i % 16))" ]; then
			printf "\n"
		fi
	done
}

sc() {
	for d in /usr/lib /usr/lib/$(uname -m)-linux-gnu; do
		s="$d/opensc-pkcs11.so"
		if test -f "$s"; then
			case "$1" in
			start) ssh-add -s "$s" ;;
			stop) ssh-add -e "$s" ;;
			*)
				echo "use sc [start|stop]"
				return 1
				;;
			esac
			return
		fi
	done
}

alias sc-start='sc start'
alias sc-stop='sc stop'

wait_host()
{
        until ping -c1 "$1" >/dev/null 2>&1; do :; done
}

case $HOSTNAME in
	SHS*)
		alias wake106='ssh pihole wakeonlan 4c:52:62:0d:10:d7 && wait_host 192.168.188.106';;
	pc???)
		alias wake107='wakeonlan 4c:52:62:0d:0f:ea && wait_host 192.168.23.107'
		alias wake130='wakeonlan d4:f5:27:e5:7b:00 && wait_host 192.168.23.130'
		alias wake131='wakeonlan d4:f5:27:e5:b0:08 && wait_host 192.168.23.131'
		;;
esac

# fzf needed from here
if ! command -v fzf >/dev/null; then
	return
fi

cdgw() {
	# Check if we're in a git repo
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		echo "Not a git repository."
		return 1
	fi
	local dir
	# shellcheck disable=SC2016
	dir=$(git worktree list --porcelain | grep '^worktree ' | cut -d' ' -f2- | fzf --height '40%' --ansi --preview='cd {} && git -c color.status=always status --short --branch && git stash list | grep $(git rev-parse --abbrev-ref HEAD)')
	if [ -n "$dir" ]; then
		cd "$dir" || echo 'hoppala!'
	fi
}
