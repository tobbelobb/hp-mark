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
	exit 0
}

trap cleanup SIGINT SIGTERM

touch ${LOGFILE}
exec 3>&1 1>>${LOGFILE} 2>&1

mkdir -p "${IMAGESERIES}/"

let "INC=1"
COUNT=""

readonly SET_ENCODER_REFERENCE_POINT="M569.3 P40.0:41.0:42.0:43.0 S"
readonly READ_ENCODERS="M569.3 P40.0:41.0:42.0:43.0"

# We assume nozzle is at the origin. Set motor encoder reference point.
curl --silent ${GCODE_ENDPOINT} -d "${SET_ENCODER_REFERENCE_POINT}" -H "Content-Type: text/plain" >/dev/null

SET_TORQUES=("M98 P\"/macros/Torque_mode\" A0     B0     C0     D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0.055 B0.055 C0.045 D0"
	"M98 P\"/macros/Torque_mode\" A0     B0.025 C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0     B0.025 C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0     B0.055 C0.045 D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0     C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0     C0.015 D0"
	"M98 P\"/macros/Torque_mode\" A0.055 B0     C0.045 D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0     D0"
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0     D0"
	"M98 P\"/macros/Torque_mode\" A0.055 B0.055 C0     D0"
)

MOTOR_MOVES=("M98 P\"/macros/Individual_motor_control\" D0    F6000"
	"M98 P\"/macros/Individual_motor_control\" D-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" D-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" D-100 F6000"
	"M98 P\"/macros/Individual_motor_control\" D-100 F6000"
	"M98 P\"/macros/Individual_motor_control\" D500  F6000"
	"M98 P\"/macros/Individual_motor_control\" A-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" A-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" A400  F6000"
	"M98 P\"/macros/Individual_motor_control\" B-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" B-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" B400  F6000"
	"M98 P\"/macros/Individual_motor_control\" C-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" C-200 F6000"
	"M98 P\"/macros/Individual_motor_control\" C400  F6000"
)

for i in "${!SET_TORQUES[@]}"; do

	printf -v COUNT "%04d" ${INC}

	# Set torque
	curl --silent ${GCODE_ENDPOINT} -d "${SET_TORQUES[i]}" -H "Content-Type: text/plain" >/dev/null
	# Do motor move
	curl --silent ${GCODE_ENDPOINT} -d "${MOTOR_MOVES[i]}" -H "Content-Type: text/plain" >/dev/null
	# Make motors stand still
	curl --silent ${GCODE_ENDPOINT} -d "M98 P\"/macros/Torque_mode\" A0 B0 C0 D0" -H "Content-Type: text/plain" >/dev/null

	MOTOR_POS_SAMP="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_ENCODERS}" -H "Content-Type: text/plain" 2>&1 | tr -d '\n')"

	### Read encoders ###
	#MOTOR_POS_SAMP="0"
	#MOTOR_POS_SAMP2="1"
	#while [ "${MOTOR_POS_SAMP}" != "${MOTOR_POS_SAMP2}" ]; do
	#	MOTOR_POS_SAMP="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_ENCODERS}" -H "Content-Type: text/plain" 2>&1 | tr -d '\n')"
	#	sleep 0.5 # Let motors move
	#	MOTOR_POS_SAMP2="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_ENCODERS}" -H "Content-Type: text/plain" 2>&1 | tr -d '\n')"
	#done
	echo -n ${MOTOR_POS_SAMP} | tee /dev/fd/3

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
cleanup
