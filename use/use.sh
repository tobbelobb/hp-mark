#!/usr/bin/env bash

# For quick hpm usage on the rpi4.
# Doesn't compile hpm.
# Invokes raspistill and creates random filename for the image.
# Reads the example params.
# Forwards -v, -s, -c or any other trailing arguments to hpm.

set -o errexit
set -o pipefail

readonly THISPATH="$(dirname "$0")"
readonly IMAGES="${THISPATH}/images"
mkdir -p "${IMAGES}/"

readonly RASPISTILL="/home/pi/repos/NativePiCamera/bin/raspistill_CS_lens"
readonly IMAGE=$(mktemp -p "${IMAGES}/" XXXXXXXXXX.jpg)
${RASPISTILL} --quality 100 -o "${IMAGE}" --width 3280 --height 2464
echo "Captured image ${IMAGE}."

readonly HPM="/home/pi/repos/hp-mark/hpm/hpm/hpm"
readonly CAMPARAMS="/home/pi/repos/hp-mark/hpm/hpm/example-cam-params/myExampleCamParams.xml"
readonly MARKERPARAMS="/home/pi/repos/hp-mark/hpm/hpm/example-marker-params/my-marker-params.xml"

readonly COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} $@"
echo $COMMAND
$COMMAND
