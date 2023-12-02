#!/bin/bash
alias quit='ssh -O exit '
alias cfg='git --git-dir=$HOME/.cfg --work-tree=$HOME '
alias curr='cat "$XDG_RUNTIME_DIR/host" 2> /dev/null || echo none'
alias rnvim='nvim --remote-ui --server 127.0.0.1:8192 '
