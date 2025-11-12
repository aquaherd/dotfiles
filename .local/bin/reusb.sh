#!/bin/sh
for b in $(sudo usbip list -r localhost 2>/dev/null | grep -oP '\d+-\d+'); do
	echo "attaching UART $b"
	sudo usbip attach -r localhost -b "$b"
done
