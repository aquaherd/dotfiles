#!/bin/sh
#
query=
if [ $# -gt 0 ]; then
    query="-q $*"
fi
loc=$(fdfind -Itf runtime.xml ~/Firmware/Integration_Test/RT/|fzf $query)
src=$(dirname ${loc} || echo "")

if test -z "$src"; then
    echo FAIL
    exit 1
fi
rm -rvf ~/Firmware/SiDaNetRuntime/* || echo 'was empty'
cp -rv $src/* ~/Firmware/SiDaNetRuntime/
echo OK
