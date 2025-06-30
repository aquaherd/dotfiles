#!/bin/sh
ours=~/.timewarrior/data/
theirs=pg2:.timewarrior/data/

rsync -av $theirs $ours && rsync -av $ours $theirs
