#!/bin/bash

# Ansible managed
x=0
while hciconfig | grep -q DOWN; do
        if [ $x -eq 20 ]; then
                exit 1
        fi
        /usr/bin/btmgmt power on
        /usr/bin/btmgmt connectable on
        x=$((x+1))
        sleep 1
done
