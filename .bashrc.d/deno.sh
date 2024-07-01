DENO_INSTALL="$HOME/.deno"
if  test -d "$DENO_INSTALL" && ! [[ $PATH =~ $DENO_INSTALL ]]; then
	PATH+=":$DENO_INSTALL/bin"
fi
