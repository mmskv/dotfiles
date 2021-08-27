#!/bin/bash
if [[ -z "$(pgrep picom)" ]] ; then
    sleep 1
    picom --config $HOME/.config/picom.config
fi
