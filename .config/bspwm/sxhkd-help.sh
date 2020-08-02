#!/usr/bin/env bash

while IFS="" read -r line; do
	if [[ "$line" =~ ^##\  ]]; then # header
		header="$line"

	elif [[ "$line" =~ ^#[^#] ]]; then # description
		desc="$line"

	elif [[ "$line" =~ ^([a-z]|[A-Z]) ]]; then # binding
		binding="$line"
		printf "%-40s %s\n" "$binding" "$desc"
	fi
done < "$HOME/.config/bspwm/sxhkd.conf" | less
