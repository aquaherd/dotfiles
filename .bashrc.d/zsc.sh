if command -v ss > /dev/null; then
	if ss -lt | grep -q 127.0.0.1:8086; then
		export http_proxy=http://127.0.0.1:8086
		export https_proxy=http://127.0.0.1:8086
	fi
fi
