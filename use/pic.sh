#!/usr/bin/env bash

# For quick hpm usage from non-pi host
#  - Ssh into the rpi4
#  - Take an image
#  - Exit ssh
#  - Download the image
#  - Runs hpm on the image
#
# Doesn't compile hpm.
# Invokes raspistill and creates random filename for the image.
# Reads the example params.
# Forwards -v, -s, -c or any other trailing arguments to hpm.

set -o errexit
set -o pipefail

readonly THISPATH="$(dirname "$0")"
readonly IMAGES="${THISPATH}/images"
readonly SERIES_NAME="tmp"
readonly RASPISTILL="/home/pi/repos/NativePiCamera/bin/raspistill_CS_lens"

while [ true ] ; do
IMAGENAME=$(mktemp --dry-run XXXXX.jpg)
IMAGE="${IMAGES}/${SERIES_NAME}/${IMAGENAME}"

USEPATH_ON_PI="/home/pi/repos/hp-mark/use"
IMAGE_ON_PI="${USEPATH_ON_PI}/images/${IMAGENAME}"

ssh pi@rpi RASPISTILL=${RASPISTILL} USEPATH_ON_PI=${USEPATH_ON_PI} IMAGE_ON_PI=${IMAGE_ON_PI} 'bash -s' <<'ENDSSH'
cd "${USEPATH_ON_PI}" && pwd && \
mkdir -p "${USEPATH_ON_PI}/images" && \
"${RASPISTILL}" --quality 100 --timeout 300 --shutter 5000 --ISO 300 -o "${IMAGE_ON_PI}" --width 3280 --height 2464 && \
echo Captured image remotely: "${IMAGE_ON_PI}".
ENDSSH

mkdir -p "${IMAGES}/${SERIES_NAME}"
cd "${IMAGES}/${SERIES_NAME}"
echo "Copies home:"
scp pi@rpi:${IMAGE_ON_PI} .
cd -
eog "${IMAGE}" &
EOG_PID=$!
sleep 2
kill ${EOG_PID}

read -n 1
done
