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
#
# If you want this script to be verbose, say
# VERBOSE=true ./use_ssh_continous.sh

set -o pipefail

SSH_PID=0
readonly SSH_PIPE="/tmp/ssh-input-for-pi"

cleanup() {
	if [ ${VERBOSE} ]; then
		echo "Running cleanup"
	fi
	if [ ${SSH_PID} -ne 0 ]; then
		echo "Waiting for ssh"
		wait ${SSH_PID}
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
	PI_CMD="cd \"${USEPATH_ON_PI}\""
	if [ ${VERBOSE} ]; then
		PI_CMD+=" && pwd"
	fi
	PI_CMD+=" && mkdir -p \"${USEPATH_ON_PI}/images\""
	PI_CMD+=" && raspistill --quality 100 -o \"${IMAGE_ON_PI}\" --width 3280 --height 2464"
	if [ ${VERBOSE} ]; then
		PI_CMD+=" && echo Captured image remotely: \"${IMAGE_ON_PI}\""
	fi
	PI_CMD+="; exit"
	echo ${PI_CMD} >>${SSH_PIPE}
	wait ${SSH_PID}
	SSH_PID=0

	cd "${IMAGES}/"
	if [ ${VERBOSE} ]; then
		echo "Copies home:"
		scp pi@rpi:${IMAGE_ON_PI} .
	else
		scp -q pi@rpi:${IMAGE_ON_PI} .
	fi
	cd - >/dev/null

	COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} $@"
	if [ ${VERBOSE} ]; then
		echo "${COMMAND}"
	fi
	$COMMAND

done
