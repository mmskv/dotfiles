#!/bin/bash
if [[ -z "$(pgrep picom)" ]] ; then
    picom
fi
