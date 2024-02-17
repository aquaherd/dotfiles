#!/bin/bash
#
query=
if [ $# -gt 0 ]; then
    query="-q $*"
fi
# shellcheck disable=2086
loc=$(fdfind -Itf runtime.xml ~/Firmware/Integration_Test/RT/|fzf $query)
src=$(dirname "${loc}" || echo "")

if test -z "$src"; then
    echo FAIL
    exit 1
fi
rm -rvf ~/Firmware/SiDaNetRuntime/* || echo 'was empty'
cp -rv "$src"/* ~/Firmware/SiDaNetRuntime/
cp -vf "${src}/../AddOns/version.py" ~/Firmware/Integration_Test/RT/
echo OK
