#!/bin/sh
# pandemy passed but still no zscaler for Linux

URI=https://nina.erduman.de/dyn/mode.html

while(true); do
  mode="$(curl $URI)"
  NUM=$(pgrep -c autossh)
  echo "mode=$mode num=$NUM"
  case "$mode" in
    start)
      if [ $NUM -lt 1 ];then
        /usr/bin/autossh -vN pg2&
      fi
      ;;
    stop) 
      if [ $NUM -gt 0 ]; then
        /usr/bin/killall autossh
      fi
      ;;
    *) echo "No such command";;
  esac
  /usr/bin/sleep 5m
done
