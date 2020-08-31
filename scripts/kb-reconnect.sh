#! /bin/sh

bluetoothctl power on
kbaddr=E0:EB:40:D0:13:B0
while [[ $(bluetoothctl info E0:EB:40:D0:13:B0) == *"Connected: no"* ]]; do
	bluetoothctl connect $kbaddr
	sleep 6
done
setxkbmap -layout us,ru -option grp:alt_space_toggle
