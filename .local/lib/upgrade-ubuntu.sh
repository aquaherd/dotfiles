#!/bin/sh
NUMUP=$(LANG=C apt-get upgrade -s |grep -P '^\d+ upgraded'|cut -d" " -f1)
echo "--> $NUMUP updates."
if [ "$NUMUP" -gt 0 ]; then
	apt-get dist-upgrade -y
	apt-get autoremove
	apt-get autoclean
fi
