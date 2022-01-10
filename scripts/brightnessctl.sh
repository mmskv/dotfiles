#!/usr/bin/env bash

# $ ./brightnessctl.sh up
# $ ./brightnessctl.sh down

function get_brightness {
    brightnessctl | grep Current | sed 's/^.*(\([0-9]*%\)).*$/\1/g'
}

function send_notification {
    brightness=$(get_brightness)
    brightness=${brightness::-1}
    # Make the bar with the special character ─ (it's not dash -)
    # https://en.wikipedia.org/wiki/Box-drawing_character
    bar=$(seq --separator="─" 0 "$((brightness / 4))" | sed 's/[0-9]//g')
    # Send the notification
    # dunstify -r 2594 -u low "Brightness" "$brightness% $bar"
    dunstify -a "changeVolume" -u low -r 2594 -h int:value:"$brightness" \
    "Brightness: ${brightness}%"

}

case $1 in
  up)
    brightnessctl --exponent=3 set +10%
    send_notification
    ;;
  down)
    brightnessctl --exponent=3 set 10%-
    send_notification
    ;;
esac
