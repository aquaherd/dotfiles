#!/bin/sh
CL=0
LOC=~/.local/share/hamster/hamster.db
CPY=~/.local/share/hamster/page.db
REM=page.db
HOST=pg2

scp $HOST:$REM $CPY
hamster-sync.py $CPY $LOC
