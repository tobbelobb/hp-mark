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


# We assume nozzle is at the origin. Set motor encoder reference point.
curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=G96 >/dev/null

for G95 in "G95 A30 B34 C5 D0" \
	"G95 A30 B5 C28 D0" \
	"G95 A5 B30 C30 D0" \
	"G95 A15 B5 C5 D24" \
	"G95 A30 B34 C5 D0" \
	"G95 A30 B5 C28 D0" \
	"G95 A5 B30 C30 D0" \
	"G95 A15 B5 C5 D27" \
	"G95 A30 B34 C5 D0" \
	"G95 A30 B5 C28 D0" \
	"G95 A5 B30 C30 D0" \
	"G95 A15 B5 C5 D35" \
	"G95 A30 B34 C5 D0" \
	"G95 A28 B6 C26 D0" \
	"G95 A5 B5 C5 D42" \
	"G95 A20 B20 C20 D15" \
	"G95 A20 B20 C20 D7"; do

	printf -v COUNT "%04d" ${INC}

	# Set torque
	curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode="${G95// /%20}" >/dev/null


	### M114 S2 ###
	# WARNING: This does not work if the web interface is running... Close the tab first.
	# Send the http request.
	# On RRF3 this needs to be changed to
	# - url: http://hp4test.local/machine/code/
	# - data: "M114 S2"
  MOTOR_POS_SAMP="0"
  MOTOR_POS_SAMP2="1"
  while [ "${MOTOR_POS_SAMP}" != "${MOTOR_POS_SAMP2}" ]; do
		curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=M114%20S2 >/dev/null
		sleep 0.1 # It takes a little while for the Duet to process M114 S2
		MOTOR_POS_SAMP="$(curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_reply 2>&1 | tr -d '\n')"

    sleep 1 # Let motors move

		curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_gcode?gcode=M114%20S2 >/dev/null
		sleep 0.1
		MOTOR_POS_SAMP2="$(curl --silent -X GET -H "application/json, text/plain, */*" http://hp4test.local/rr_reply 2>&1 | tr -d '\n')"
  done
	echo -n ${MOTOR_POS_SAMP} | tee /dev/fd/3

	IMAGE="${IMAGESERIES}/${COUNT}.jpg"
	IMAGE_ON_PI="${IMAGESERIES_ON_PI}/${COUNT}.jpg"

	rm -f ${SSH_PIPE}
	mkfifo ${SSH_PIPE}
	tail -f ${SSH_PIPE} | ssh pi@rpi RASPISTILL=${RASPISTILL} USEPATH_ON_PI=${USEPATH_ON_PI} IMAGE_ON_PI=${IMAGE_ON_PI} 'bash -s' 2>&1 | tee /dev/fd/3 &
	SSH_PID=$!
	PI_CMD="cd \"${USEPATH_ON_PI}\""
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
