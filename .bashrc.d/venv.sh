#!/bin/bash
if [ -d ~/.venv ]; then
	a=$(ls -1 ~/.venv)
	for dir in $a; do
		#shellcheck disable=SC2139
		alias "$dir"=". ~/.venv/$dir/bin/activate"
	done
fi
