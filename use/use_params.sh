#!/usr/bin/env bash

## Sets readonly variables for all the use-sripts

THISPATH_TMP="${BASH_SOURCE%/*}"
if [[ ! -d "$THISPATH_TMP" ]]; then THISPATH_TMP="$PWD"; fi

SERIESNAME_TMP=$(mktemp --dry-run XXXXX)
if [ ${DATA_SERIES_NAME} ]; then SERIESNAME_TMP="${DATA_SERIES_NAME}"; fi


readonly THISPATH="${THISPATH_TMP}"
readonly GCODE_ENDPOINT="http://duet3.local/machine/code/"
readonly IMAGES="${THISPATH}/images"
readonly SSH_PIPE="/tmp/ssh-input-for-pi"
readonly USEPATH_ON_PI="/home/pi/repos/hp-mark/use"
readonly HPM="../hpm/hpm/hpm"
readonly CAMPARAMS="../hpm/hpm/example-cam-params/loDistCamParams2.xml"
readonly MARKERPARAMS="../hpm/hpm/example-marker-params/my-marker-params.xml"
readonly SERIESNAME="${SERIESNAME_TMP}"
readonly LOGFILE="logs/${SERIESNAME}.log"
readonly IMAGESERIES="${IMAGES}/${SERIESNAME}"
readonly IMAGESERIES_ON_PI="${USEPATH_ON_PI}/images/${SERIESNAME}"
readonly SINGLE_IMAGE="${IMAGES}/${SERIESNAME}.jpg"
readonly SINGLE_IMAGE_ON_PI="${USEPATH_ON_PI}/images/${SERIESNAME}.jpg"
readonly LIGHTS_ON_CMD="sudo python3 /home/pi/repos/rpi_ws281x/python/examples/tobben_constant_light.py > /dev/null"
readonly LIGHTS_OFF_CMD="sudo python3 /home/pi/repos/rpi_ws281x/python/examples/lights_off.py > /dev/null"

# Shutter: Recommend 15000 in daylight, 150000 in low light
# Timeout: Set as low as possible to prevent image chip from getting so hot it warps
# ISO: Set as low as possible to minimize image noise
# Width and height: Maximize potential of image sensor
readonly RASPISTILL="/home/pi/repos/NativePiCamera/bin/raspistill_CS_lens"
readonly IMAGE_COMMAND_EXCEPT_O="${RASPISTILL} --quality 100 --timeout 300 --shutter 150000 --ISO 50 --width 3280 --height 2464"

## Cleanup

unset THISPATH_TMP
unset SERIESNAME_TMP
