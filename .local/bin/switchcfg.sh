#!/bin/sh
#
query=
if [ $# -gt 0 ]; then
    query="-q $*"
fi
loc=$(fdfind -Itf config_255.xml ~/Firmware/Integration_Test/CFG/|fzf $query)
src=$(dirname "${loc}" || echo "")

if test -z "$src"; then
    echo FAIL
    exit 1
fi
rm -rvf ~/Firmware/SiDaNetConfiguration/* || echo 'was empty'
cp -rv "$src"/* ~/Firmware/SiDaNetConfiguration/
echo OK
