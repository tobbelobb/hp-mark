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

source "./use_params.sh"

SSH_PID=0

cleanup() {
	if [ ${VERBOSE} ]; then
		echo "Running cleanup" 2>&1 | tee /dev/fd/3
	fi
	if [ ${SSH_PID} -ne 0 ]; then
		echo "Waiting for ssh" 2>&1 | tee /dev/fd/3
		wait ${SSH_PID}
		rm -f ${SSH_PIPE}
	fi
	exit 0
}

trap cleanup SIGINT SIGTERM

touch ${LOGFILE}
exec 3>&1 1>>${LOGFILE} 2>&1
if [ ${VERBOSE} ]; then
	echo "Creating log file: ${LOGFILE}" 2>&1 | tee /dev/fd/3
fi

PI_CMD="mkdir -p \"${USEPATH_ON_PI}/images/\""
PI_CMD+=" && ${LIGHTS_ON_CMD}"
PI_CMD+=" && "${IMAGE_COMMAND_EXCEPT_O}" -o \"${SINGLE_IMAGE_ON_PI}\""
PI_CMD+=" && ${LIGHTS_OFF_CMD}"
if [ ${VERBOSE} ]; then
	PI_CMD+=" && echo \"Captured image remotely: ${SINGLE_IMAGE_ON_PI}\""
fi
PI_CMD+="; exit"

rm -f ${SSH_PIPE}
mkfifo ${SSH_PIPE}
tail -f ${SSH_PIPE} | ssh pi@rpi 'bash -s' 2>&1 | tee /dev/fd/3 &
SSH_PID=$!
echo ${PI_CMD} >>${SSH_PIPE}
wait ${SSH_PID}
SSH_PID=0

mkdir -p "${IMAGES}/"
if [ ${VERBOSE} ]; then
	echo "Copies home image ${SINGLE_IMAGE}" 2>&1 | tee /dev/fd/3
fi
scp pi@rpi:${SINGLE_IMAGE_ON_PI} ${SINGLE_IMAGE}

readonly COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${SINGLE_IMAGE} $@"
if [ ${VERBOSE} ]; then
	echo "${COMMAND}" 2>&1 | tee /dev/fd/3
fi
$COMMAND 2>&1 | tee /dev/fd/3
