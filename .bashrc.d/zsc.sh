if grep -q microsoft /proc/version; then
	return
fi
if [[ -n "$DEV_CONTAINER_NAME" ]] || [[ -n "$container" ]]; then
        return
fi 
if command -v ss > /dev/null; then
	if ss -lt | grep -q 127.0.0.1:8086; then
		if ! pidof -q tinyproxy; then
			export http_proxy=http://127.0.0.1:8086
			export https_proxy=http://127.0.0.1:8086
		fi
	fi
fi
