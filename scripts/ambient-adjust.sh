#!/bin/env bash
# Adjust the monitor's brightness based on information from the ambient light sensor (ALS)
# 
# Tested only on a Macbook Pro 16,1. No idea how well it'll work on other systems.
# I assume no responsibility if this script unleashes gremlins and bricks
# your device. Use at your own risk.
#
# TODO: Add multi-monitor support

# Feel free to changes these as needed
MONITOR=acpi_video0
SENSOR=iio:device0
ADAPTER=ADP1

# How often to check the ALS in seconds.
# Default: 0 (match ALS's frequency, i.e. as fast as the device allows)
POLLING_PER=3

# Values read by the ALS for which the screen should be dimmest or brightest
# Default: 1000 and 900000
MIN_LUX=1000
MAX_LUX=100000

# Amount that ambient brightness must change before we change the screen brightness
# Default: 0.1
BRI_THRESHOLD_FRAC=0.1

# What to modify the brightness by when the laptop is unplugged
# Default: 0.9
BRI_UNPLUGGED_MODIFIER=0.9

BACKLIGHT_DIR="/sys/class/backlight/$MONITOR"
BRI_FILE="${BACKLIGHT_DIR}/brightness"

MIN_BRI=1
MAX_BRI=$(cat "${BACKLIGHT_DIR}/max_brightness")

if [[ $POLLING_FREQ == 0 ]]; then
    SENSOR_FREQ=$(cat /sys/bus/iio/devices/$SENSOR/in_illuminance_sampling_frequency)
    POLLING_PER=$(echo "1/$SENSOR_FREQ" | bc)
fi

AMBI_BRI_OLD=$(cat "$BRI_FILE")
PLUG_STATUS_OLD=$(cat /sys/class/power_supply/$ADAPTER/online)

#######################################
# Adjust brightness based on lux value
# GLOBALS:
#   MIN_LUX, MAX_LUX, MIN_BRI, MAX_BRI,
#   BRI_THRESHOLD_FRAC, BRI_UNPLUGGED_MODIFIER,
#   BRI_FILE, PLUG_STATUS_OLD, AMBI_BRI_OLD
# ARGUMENTS:
#   Lux value
# OUTPUTS:
#   Write new brightness to BRI_FILE
# RETURN:
#   0 if print succeeds, non-zero on error
#######################################
change_brightness() {
    lux=$1

    # Ensure the lux value is within range.
    [[ $lux -lt $MIN_LUX ]] && lux=$MIN_LUX
    [[ $lux -gt $MAX_LUX ]] && lux=$MAX_LUX

    # Percentages are in logspace since humans see logarithmically
    ambi_bri_frac=$(echo "(l($lux)-l($MIN_LUX))/(l($MAX_LUX)-l($MIN_LUX))" | bc -l)

    plug_status=$(cat /sys/class/power_supply/$ADAPTER/online)
    [[ $plug_status -eq 0 ]] && ambi_bri_frac=$(echo "$ambi_bri_frac*$BRI_UNPLUGGED_MODIFIER" | bc -l)

    ambi_bri_frac_old=$(echo "(l($AMBI_BRI_OLD)-l($MIN_BRI))/(l($MAX_BRI)-l($MIN_BRI))" | bc -l)
    frac_diff=$(echo "$ambi_bri_frac-$ambi_bri_frac_old" | bc)

    # Only change the brightness if the threshhold has been reached or if the computer was plugged/unplugged
    (( $(echo "${frac_diff#-} > $BRI_THRESHOLD_FRAC" | bc) )) && change_bri=true || change_bri=false
    [[ $plug_status -ne $PLUG_STATUS_OLD ]] && change_bri=true

    ambi_bri_float=$(echo "e(l($MAX_BRI)*$ambi_bri_frac)" | bc -l)
    ambi_bri=$(echo "scale=0;($ambi_bri_float+0.5)/1" | bc)

    [[ $ambi_bri -le 0 ]] && ambi_bri=1

    $change_bri && echo $ambi_bri > "$BRI_FILE"

    AMBI_BRI_OLD=$ambi_bri
    PLUG_STATUS_OLD=$plug_status
}

while true; do
    sleep $POLLING_PER
    grep -q closed /proc/acpi/button/lid/LID0/state && continue
    lux=$(cat /sys/bus/iio/devices/$SENSOR/in_illuminance_input)
    change_brightness "$lux"
done
