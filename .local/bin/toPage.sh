#!/bin/sh
LOC=~/.local/share/hamster/hamster.db
CPY=~/.local/share/hamster/page.db
REM=page.db
HOST=pg2

scp $HOST:$REM $CPY
hamster-sync.py $LOC $CPY
scp $CPY $HOST:$REM
