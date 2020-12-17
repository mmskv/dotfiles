#!/bin/bash
if [[ -z "$(pgrep picom)" ]] ; then
    sleep 1
    picom
fi
