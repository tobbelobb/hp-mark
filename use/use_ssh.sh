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
readonly IMAGENAME=$(mktemp --dry-run XXXXX.jpg)
readonly IMAGE="${IMAGES}/${IMAGENAME}"

readonly USEPATH_ON_PI="/home/pi/repos/hp-mark/use"
readonly IMAGE_ON_PI="${USEPATH_ON_PI}/images/${IMAGENAME}"

ssh pi@rpi USEPATH_ON_PI=${USEPATH_ON_PI} IMAGE_ON_PI=${IMAGE_ON_PI} 'bash -s' <<'ENDSSH'
cd "${USEPATH_ON_PI}" && pwd && \
mkdir -p "${USEPATH_ON_PI}/images" && \
raspistill --quality 100 -o "${IMAGE_ON_PI}" --width 3280 --height 2464 && \
echo Captured image remotely: "${IMAGE_ON_PI}".
ENDSSH

mkdir -p "${IMAGES}/"
cd "${IMAGES}/"
echo "Copies home:"
scp pi@rpi:${IMAGE_ON_PI} .
cd -

readonly HPM="../hpm/hpm/hpm"
readonly CAMPARAMS="../hpm/hpm/example-cam-params/myExampleCamParams.xml"
readonly MARKERPARAMS="../hpm/hpm/example-marker-params/my-marker-params.xml"

readonly COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} $@"
echo "Will execute:"
echo "${COMMAND}"
$COMMAND