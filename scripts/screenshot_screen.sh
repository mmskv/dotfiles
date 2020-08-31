#!/bin/bash

# This script intercepts specific user selections and replaces them with monitor geometry.
# The specific user selection is when they click on the root window, or attempt to select the whole X screen.
# Currently there is a bug, clicking and dragging the entire screen will still proc the replacement,
# and only screenshot the monitor that the mouse is on after the drag. There's no way around this without
# changing slop to indicate when a user clicked or dragged. (Which might be done if people care enough.)

# Get a normal selection
read -r X Y W H G ID < <(slop -f "%x %y %w %h %g %i")

# Get the window id of the root window.
ROOTID=$(xwininfo -root -int | awk '/^xwininfo/ {print $4}')
# We grab the root geometry too, to detect if the user simply clicked on the root window.
ROOTGEO=$(xwininfo -root | awk '/geometry/ {print $2}')
ROOTW=$(echo ${ROOTGEO} | awk -F "[x+]" '{print $1}')
ROOTH=$(echo ${ROOTGEO} | awk -F "[x+]" '{print $2}')
# Get the location of the mouse
XMOUSE=$(xdotool getmouselocation | awk -F "[: ]" '{print $2}')
YMOUSE=$(xdotool getmouselocation | awk -F "[: ]" '{print $4}')
# Get every monitor geometry connected to this xscreen.
MONITORS=$(xrandr | grep -o '[0-9]*x[0-9]*[+-][0-9]*[+-][0-9]*')

# Now check to see if we've selected the root window
if [ "${ROOTID}" == "${ID}" ]; then
  # This is to make sure we actually clicked on it.
  if [ "${ROOTW}" == "${W}" ] && [ "${ROOTH}" == "${H}" ]; then
    # Check which monitor the mouse is on.
    for mon in ${MONITORS}; do
      # Parse the geometry of the monitor
      MONW=$(echo ${mon} | awk -F "[x+]" '{print $1}')
      MONH=$(echo ${mon} | awk -F "[x+]" '{print $2}')
      MONX=$(echo ${mon} | awk -F "[x+]" '{print $3}')
      MONY=$(echo ${mon} | awk -F "[x+]" '{print $4}')
      # Use a simple collision check
      if (( ${XMOUSE} >= ${MONX} )); then
        if (( ${XMOUSE} <= ${MONX}+${MONW} )); then
          if (( ${YMOUSE} >= ${MONY} )); then
            if (( ${YMOUSE} <= ${MONY}+${MONH} )); then
              # We have found our monitor!
              maim -g"${MONW}x${MONH}+${MONX}+${MONY}" --format=png | xclip -selection clipboard -t image/png
              exit 0
            fi
          fi
        fi
      fi
    done
  fi
fi

# Otherwise, we must have selected a different window or geometry, so we just screenshot it normally.
maim -g"${G}" -i"${ID}" --format=png | xclip -selection clipboard -t image/png
