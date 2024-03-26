#!/bin/bash
__start_sh() 
{
	local pcs="win105 win106 win107 win108 win109 win131 win200 win246 win247 win248 win249"
	if [ "${#COMP_WORDS[@]}" == "2" ]; then
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "$pcs" "${COMP_WORDS[1]}"))
	elif [ "${#COMP_WORDS[@]}" -gt "2" ]; then
		return 1
	fi
}

complete -F __start_sh start.sh
