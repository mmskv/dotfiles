#! /bin/bash

kbaddr=E0:EB:40:D0:13:B0
if [[ $(bluetoothctl show) == *"Powered: yes"* ]]; then
    if [[ $(bluetoothctl info E0:EB:40:D0:13:B0) == *"Connected: yes"* ]]; then
        echo ""
    else
        echo ""
    fi
else
    echo ""
fi
