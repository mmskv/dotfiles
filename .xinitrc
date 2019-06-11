#! /bin/bash
compton &
nitrogen --restore &
exec i3
wal -R &
xrandr --output DVI-D-1 --auto --output DVI-I-1 --auto --pos 1920x450
