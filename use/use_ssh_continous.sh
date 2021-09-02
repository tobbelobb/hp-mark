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
#
# Your images will get saved into a subdirectory ./images/<something>
# You will also get a log file called ./logs/<something>.log
# By default, <something> will be set to a random six character name.
# If you want to set it explicitly do:
# DATA_SERIES_NAME="my-awesome-data-collection" ./use_ssh_continous.ssh

set -o pipefail

SSH_PID=0
readonly SSH_PIPE="/tmp/ssh-input-for-pi"

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

readonly THISPATH="$(dirname "$0")"
readonly IMAGES="${THISPATH}/images"

readonly USEPATH_ON_PI="/home/pi/repos/hp-mark/use"

readonly HPM="../hpm/hpm/hpm"
#readonly CAMPARAMS="../hpm/hpm/example-cam-params/myExampleCamParams.xml"
readonly CAMPARAMS="../hpm/hpm/example-cam-params/loDistCamParams2.xml"
readonly MARKERPARAMS="../hpm/hpm/example-marker-params/my-marker-params.xml"

readonly RASPISTILL="/home/pi/repos/NativePiCamera/bin/raspistill_CS_lens"
SERIESNAME=$(mktemp --dry-run XXXXX)
if [ ${DATA_SERIES_NAME} ]; then
	SERIESNAME="${DATA_SERIES_NAME}"
fi
readonly LOGFILE="logs/${SERIESNAME}.log"
touch ${LOGFILE}
exec 3>&1 1>>${LOGFILE} 2>&1

readonly IMAGESERIES="${IMAGES}/${SERIESNAME}"
mkdir -p "${IMAGESERIES}/"

readonly IMAGESERIES_ON_PI="${USEPATH_ON_PI}/images/${SERIESNAME}"

let "INC=1"
COUNT=""

while true; do

	printf -v COUNT "%04d" ${INC}
	IMAGE="${IMAGESERIES}/${COUNT}.jpg"
	IMAGE_ON_PI="${IMAGESERIES_ON_PI}/${COUNT}.jpg"

	rm -f ${SSH_PIPE}
	mkfifo ${SSH_PIPE}
	tail -f ${SSH_PIPE} | ssh pi@rpi RASPISTILL=${RASPISTILL} USEPATH_ON_PI=${USEPATH_ON_PI} IMAGE_ON_PI=${IMAGE_ON_PI} 'bash -s' 2>&1 | tee /dev/fd/3 &
	SSH_PID=$!
	PI_CMD="mkdir -p \"${USEPATH_ON_PI}\" && cd \"${USEPATH_ON_PI}\""
	if [ ${VERBOSE} ]; then
		PI_CMD+=" && pwd"
	fi
	PI_CMD+=" && mkdir -p \"${IMAGESERIES_ON_PI}/\""
	PI_CMD+=" && sudo python3 /home/pi/repos/rpi_ws281x/python/examples/tobben_constant_light.py > /dev/null"
	PI_CMD+=" && "${RASPISTILL}" --quality 100 --timeout 300 --shutter 150000 --ISO 50 -o \"${IMAGE_ON_PI}\" --width 3280 --height 2464"
	PI_CMD+=" && sudo python3 /home/pi/repos/rpi_ws281x/python/examples/lights_off.py > /dev/null"
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
