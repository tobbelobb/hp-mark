#!/usr/bin/env bash

# This script tries to move the Hangprinter around and collect auto calibration data.
# It sends gcodes to the Hangprinter, and collects images from Raspberry pi.
# It then runs hpm locally on the image.

# WARNING! Before you run this command, it is assumet that you have put your effector
# in the home position, with the nozzle at the origin, and with all lines non-slack.

# hpm is given --try-hard option by default
# You can append the command with other hpm options if you want, like
#
# $get_auto_calibration_data_automatically.sh --show result
#
# ... whill stop to show result during each invocation of hpm.

# Your will get images saved into a subdirectory ./images/<something>
# You will also get a log file called ./logs/<something>.log
# By default, <something> will be set to a random six character name.
# If you want to set it explicitly do:
# DATA_SERIES_NAME="my-awesome-data-collection" ./get_auto_calibration_data_automatically.sh

# Copy/paste friendly, filtered versions of the data strings will be printed out at the end.

# Stop the program with ctrl-C, or by waiting until it finishes by itself

set -o pipefail

readonly GCODE_ENDPOINT="http://duet3.local/machine/code/"

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

readonly THISPATH="$(dirname "$0")"
readonly IMAGES="${THISPATH}/images"

readonly USEPATH_ON_PI="/home/pi/repos/hp-mark/use"

readonly HPM="../hpm/hpm/hpm"
readonly CAMPARAMS="../hpm/hpm/example-cam-params/loDistCamParams2.xml"
readonly MARKERPARAMS="../hpm/hpm/example-marker-params/my-marker-params.xml"

readonly RASPISTILL="/home/pi/repos/NativePiCamera/bin/raspistill_CS_lens"
readonly SHUTTER="15000" # In daylight
#readonly SHUTTER="150000" # In low light
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

readonly SET_ENCODER_REFERENCE_POINT="M569.3 P40.0:41.0:42.0:43.0 S"
readonly READ_ENCODERS="M569.3 P40.0:41.0:42.0:43.0"

# We assume nozzle is at the origin. Set motor encoder reference point.
curl --silent ${GCODE_ENDPOINT} -d "${SET_ENCODER_REFERENCE_POINT}" >/dev/null

for SET_TORQUES in "M98 P\"/macros/Torque_mode\" A0.09 B0.09 C0.01 D0" \
	"M98 P\"/macros/Torque_mode\" A0.08  B0.025 C0.08  D0" \
	"M98 P\"/macros/Torque_mode\" A0.025 B0.08  C0.08  D0" \
	"M98 P\"/macros/Torque_mode\" A0.08  B0.03  C0.02  D0.065" \
	"M98 P\"/macros/Torque_mode\" A0.08  B0.09  C0.01  D0" \
	"M98 P\"/macros/Torque_mode\" A0.08  B0.025 C0.08  D0" \
	"M98 P\"/macros/Torque_mode\" A0.025 B0.09  C0.08  D0" \
	"M98 P\"/macros/Torque_mode\" A0.04  B0.025 C0.02  D0.075" \
	"M98 P\"/macros/Torque_mode\" A0.085 B0.095 C0.02  D0" \
	"M98 P\"/macros/Torque_mode\" A0.085 B0.02  C0.09  D0" \
	"M98 P\"/macros/Torque_mode\" A0.025 B0.1   C0.1   D0" \
	"M98 P\"/macros/Torque_mode\" A0.025 B0.025 C0.025 D0.085" \
	"M98 P\"/macros/Torque_mode\" A0.1   B0.1   C0.01  D0" \
	"M98 P\"/macros/Torque_mode\" A0.1   B0.01  C0.1   D0" \
	"M98 P\"/macros/Torque_mode\" A0.01  B0.1   C0.1   D0" \
	"M98 P\"/macros/Torque_mode\" A0.02  B0.02  C0.02  D0.095" \
	"M98 P\"/macros/Torque_mode\" A0.08  B0.08  C0.08  D0.015" \
	"M98 P\"/macros/Torque_mode\" A0.085 B0.085 C0.085 D0.005"; do

	printf -v COUNT "%04d" ${INC}

	# Set torque
	curl --silent ${GCODE_ENDPOINT} -d "${SET_TORQUES}" >/dev/null

	### Read encoders ###
	MOTOR_POS_SAMP="0"
	MOTOR_POS_SAMP2="1"
	while [ "${MOTOR_POS_SAMP}" != "${MOTOR_POS_SAMP2}" ]; do
		MOTOR_POS_SAMP="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_ENCODERS}" 2>&1 | tr -d '\n')"
		sleep 0.5 # Let motors move
		MOTOR_POS_SAMP2="$(curl --silent ${GCODE_ENDPOINT} -d "${READ_ENCODERS}" 2>&1 | tr -d '\n')"
	done
	echo -n ${MOTOR_POS_SAMP} | tee /dev/fd/3

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
	PI_CMD+=" && "${RASPISTILL}" --quality 100 --timeout 300 --shutter "${SHUTTER}" --ISO 50 -o \"${IMAGE_ON_PI}\" --width 3280 --height 2464"
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

	COMMAND="${HPM} ${CAMPARAMS} ${MARKERPARAMS} ${IMAGE} --try-hard $@"
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
