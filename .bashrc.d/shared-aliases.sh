#!/bin/bash
alias cdgr='cd $(git rev-parse --show-toplevel||echo .)'
alias cfg='git --git-dir=$HOME/.cfg --work-tree=$HOME '
alias curr='cat "$XDG_RUNTIME_DIR/host" 2> /dev/null || echo none'
alias quit='ssh -O exit '
alias rnvim='nvim --remote-ui --server 127.0.0.1:8192 '

colors()
{
	for i in {0..255} ; do
		printf "\x1b[38;5;%sm%03d " "${i}" "${i}"
		if [ "15" = "$((i%16))" ]; then
			printf "\n"
		fi
	done
}
