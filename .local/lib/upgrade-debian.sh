#!/bin/sh
apt-get update -y > /dev/null
NUMUP=$(LANG=C apt-get upgrade -ys |grep -P '^\d+ upgraded'|cut -d" " -f1)
echo "--> $NUMUP updates."
if [ "$NUMUP" -gt 0 ]; then
	apt-get dist-upgrade -y
	apt-get autoremove -y
	apt-get autoclean -y
fi
