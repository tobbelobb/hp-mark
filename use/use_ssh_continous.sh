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

set -o pipefail

SSH_PID=0
readonly SSH_PIPE="/tmp/ssh-input-for-pi"

cleanup() {
	echo "Ran cleanup"
	if [ ${SSH_PID} -ne 0 ]; then
		echo "Killed ssh"
		kill -s SIGTERM ${SSH_PID}
		rm -f ${SSH_PIPE}
	fi
	exit 0
}

trap cleanup SIGINT SIGTERM

readonly THISPATH="$(dirname "$0")"
readonly IMAGES="${THISPATH}/images"
mkdir -p "${IMAGES}/"

readonly USEPATH_ON_PI="/home/pi/repos/hp-mark/use"

readonly HPM="../hpm/hpm/hpm"
readonly CAMPARAMS="../hpm/hpm/example-cam-params/myExampleCamParams.xml"
readonly MARKERPARAMS="../hpm/hpm/example-marker-params/my-marker-params.xml"

while true; do
	IMAGENAME=$(mktemp --dry-run XXXXX.jpg)
	IMAGE="${IMAGES}/${IMAGENAME}"
	IMAGE_ON_PI="${USEPATH_ON_PI}/images/${IMAGENAME}"

	rm -f ${SSH_PIPE}
	mkfifo ${SSH_PIPE}
	tail -f ${SSH_PIPE} | ssh pi@rpi USEPATH_ON_PI=${USEPATH_ON_PI} IMAGE_ON_PI=${IMAGE_ON_PI} 'bash -s' &
	SSH_PID=$!
	echo "cd \"${USEPATH_ON_PI}\" && pwd && \
        mkdir -p \"${USEPATH_ON_PI}/images\" && \
        raspistill --quality 100 -o \"${IMAGE_ON_PI}\" --width 3280 --height 2464 && \
        echo Captured image remotely: \"${IMAGE_ON_PI}\"" >>${SSH_PIPE}
	echo "exit" >>${SSH_PIPE}
	wait ${SSH_PID}
	SSH_PID=0

	cd "${IMAGES}/"
	echo "Copies home:"
	scp pi@rpi:${IMAGE_ON_PI} .
	cd -

	COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} $@"
	echo "${COMMAND}"
	$COMMAND

done
