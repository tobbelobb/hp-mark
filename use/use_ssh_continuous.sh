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
# VERBOSE=true ./use_ssh_continuous.sh
#
# Your images will get saved into a subdirectory ./images/<something>
# You will also get a log file called ./logs/<something>.log
# By default, <something> will be set to a random six character name.
# If you want to set it explicitly do:
# DATA_SERIES_NAME="my-awesome-data-collection" ./use_ssh_continuous.ssh

set -o pipefail

source "./use_params.sh"

SSH_PID=0

XYZ_OF_SAMP=""
XYZ_OF_SAMPS=""
MOTOR_POS_SAMP=""
MOTOR_POS_SAMPS=""

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

mkdir -p "${IMAGESERIES}/"

let "INC=1"
COUNT=""

while true; do

	printf -v COUNT "%04d" ${INC}
	IMAGE="${IMAGESERIES}/${COUNT}.jpg"
	IMAGE_ON_PI="${IMAGESERIES_ON_PI}/${COUNT}.jpg"

	rm -f ${SSH_PIPE}
	mkfifo ${SSH_PIPE}
	tail -f ${SSH_PIPE} | ssh pi@rpi 'bash -s' 2>&1 | tee /dev/fd/3 &
	SSH_PID=$!
	PI_CMD="mkdir -p \"${IMAGESERIES_ON_PI}/\""
	PI_CMD+=" && ${LIGHTS_ON_CMD}"
	PI_CMD+=" && "${IMAGE_COMMAND_EXCEPT_O}" -o \"${IMAGE_ON_PI}\""
	PI_CMD+=" && ${LIGHTS_OFF_CMD}"
	if [ ${VERBOSE} ]; then
		PI_CMD+=" && echo Captured image remotely: \"${IMAGE_ON_PI}\""
	fi
	PI_CMD+="; exit"
	echo ${PI_CMD} >>${SSH_PIPE}
	wait ${SSH_PID}
	SSH_PID=0

	if [ ${VERBOSE} ]; then
		echo "Copies home:" 2>&1 | tee /dev/fd/3
		scp pi@rpi:${IMAGE_ON_PI} ${IMAGE} 2>&1 | tee /dev/fd/3
	else
		scp -q pi@rpi:${IMAGE_ON_PI} ${IMAGE} 2>&1 | tee /dev/fd/3
	fi

	COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} $@"
	if [ ${VERBOSE} ]; then
		echo "${COMMAND}" 2>&1 | tee /dev/fd/3
	fi
	XYZ_OF_SAMP="$($COMMAND 2>&1)"
	echo ${XYZ_OF_SAMP} | tee /dev/fd/3

	if ! [[ "${XYZ_OF_SAMP}" =~ .*Warning.* ]]; then
		if [ "${XYZ_OF_SAMP}" != "Could not identify markers" ]; then
			MOTOR_POS_SAMPS+="${MOTOR_POS_SAMP}
"
			XYZ_OF_SAMP_WITH_COMMA_NEWLINE="${XYZ_OF_SAMP%?},
"
			XYZ_OF_SAMPS+=${XYZ_OF_SAMP_WITH_COMMA_NEWLINE}
		fi
	fi

	let "INC=INC+1"
done
