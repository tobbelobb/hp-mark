#!/usr/bin/env bash

# This script tries to move the Hangprinter around and collect auto calibration data.
# It sends gcodes to the Hangprinter, and collects images from Raspberry pi.
# It then runs hpm locally on the image.

# WARNING! Before you run this command, it is assumed that you have put your effector
# in the home position, with the nozzle at the origin, and with all lines non-slack.

# hpm is given no options by default
# recommended options are
#
#  --try-hard
#  --bed-reference (this requires bed reference actually being configured first)
#  --show result (this makes the script pause and show you the image after every measurement)
#
# You can append the command with hpm options like this:
#
# $ get_auto_calibration_data_automatically.sh --try-hard --bed-reference --show result

# Your will get images saved into a subdirectory ./images/<something>
# You will also get a log file called ./logs/<something>.log
# By default, <something> will be set to a random six character name.
# If you want to set it explicitly do:
# $ DATA_SERIES_NAME="my-awesome-data-collection" ./get_auto_calibration_data_automatically.sh

# Copy/paste friendly, filtered versions of the data strings will be printed out at the end.

# Stop the program with ctrl-C, or by waiting until it finishes by itself

set -o pipefail

source "./use_params.sh"

SSH_PID=0
XYZ_OF_SAMP=""
XYZ_OF_SAMPS=""
MOTOR_POS_SAMP=""
MOTOR_POS_SAMPS=""
FORCE_SAMP=""
FORCE_SAMPS=""

cleanup() {
	if [ ${VERBOSE} ]; then
		echo "Running cleanup" 2>&1 | tee /dev/fd/3
	fi
	if [ ${SSH_PID} -ne 0 ]; then
		echo "Waiting for ssh" 2>&1 | tee /dev/fd/3
		wait ${SSH_PID}
		rm -f ${SSH_PIPE}
	fi

	echo "" | tee /dev/fd/3
	echo "" | tee /dev/fd/3
	echo "xyz_of_samp = np.array([" | tee /dev/fd/3
	echo -n "${XYZ_OF_SAMPS}" | tee /dev/fd/3
	echo "])" | tee /dev/fd/3

	echo "" | tee /dev/fd/3
	echo "motor_pos_samp = np.array([" | tee /dev/fd/3
	echo -n "${MOTOR_POS_SAMPS}" | tee /dev/fd/3
	echo "])" | tee /dev/fd/3

	echo "" | tee /dev/fd/3
	echo "force_samp = np.array([" | tee /dev/fd/3
	echo -n "${FORCE_SAMPS}" | tee /dev/fd/3
	echo "])" | tee /dev/fd/3
	exit 0
}

trap cleanup SIGINT SIGTERM

mkdir -p "${THISPATH}/logs"
mkdir -p "${IMAGES}"

touch ${LOGFILE}
exec 3>&1 1>>${LOGFILE} 2>&1

mkdir -p "${IMAGESERIES}/"

let "INC=1"
COUNT=""

readonly SET_ENCODER_REFERENCE_POINT="M569.3 P40.0:41.0:42.0:43.0 S"
readonly READ_ENCODERS="M569.3 P40.0:41.0:42.0:43.0"
readonly READ_FORCES="M569.8 P40.0:41.0:42.0:43.0"

# We assume nozzle is at the origin. Set motor encoder reference point.
curl --silent ${GCODE_ENDPOINT} -d "${SET_ENCODER_REFERENCE_POINT}" -H "Content-Type: text/plain" >/dev/null

NUMBER_OF_SAMPLES=25

for i in $(seq 1 ${NUMBER_OF_SAMPLES}); do

	printf -v COUNT "%04d" ${INC}
	let "SAMPLES_LEFT=NUMBER_OF_SAMPLES - INC + 1"

	# Wait for user to push mover around
	read -p "Press enter to continue, or Ctrl-C to finish, ${SAMPLES_LEFT} measurements left." 2>&1 | tee /dev/fd/3

	MOTOR_POS_SAMP="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_ENCODERS}" -H "Content-Type: text/plain" 2>&1 | tr -d '\n')"
	echo -n ${MOTOR_POS_SAMP} | tee /dev/fd/3

	FORCE_SAMP="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_FORCES}" -H "Content-Type: text/plain" 2>&1 | tr -d '\n')"
	echo -n ${FORCE_SAMP} | tee /dev/fd/3

	IMAGE="${IMAGESERIES}/${COUNT}.jpg"
	IMAGE_ON_PI="${IMAGESERIES_ON_PI}/${COUNT}.jpg"

	rm -f ${SSH_PIPE}
	mkfifo ${SSH_PIPE}
	tail -f ${SSH_PIPE} | ssh ${SSH_TO} 'bash -s' 2>&1 | tee /dev/fd/3 &
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
			FORCE_SAMPS+="${FORCE_SAMP}
"
			XYZ_OF_SAMP_WITH_COMMA_NEWLINE="${XYZ_OF_SAMP%?},
"
			XYZ_OF_SAMPS+=${XYZ_OF_SAMP_WITH_COMMA_NEWLINE}
		fi
	fi

	let "INC=INC+1"
done
cleanup
