#!/usr/bin/env bash

# For quick hpm usage on the rpi4.
# Assumes hpm binary is already compiled and available on the Raspberry Pi.
# Invokes rpicam-still and creates random filename for the image.
# Reads the example params.
# Forwards -v, -s, -c or any other trailing arguments to hpm.

set -o errexit
set -o pipefail

source "./use_params.sh"

mkdir -p "${IMAGES}/"
readonly IMAGE=$(mktemp -p "${IMAGES}/" XXXXXXXXXX.jpg)

${IMAGE_COMMAND_EXCEPT_O} -o "${IMAGE}"
echo "Captured image ${IMAGE}."

readonly COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} $@"
echo $COMMAND
$COMMAND
