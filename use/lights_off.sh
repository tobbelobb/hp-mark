#!/usr/bin/env bash

# I'd rather have a light switch. But this script is what I have instead.

set -o errexit
set -o pipefail

ssh ${SSH_TO} USEPATH_ON_PI=${USEPATH_ON_PI} IMAGE_ON_PI=${IMAGE_ON_PI} 'bash -s' <<'ENDSSH'
cd /home/pi/repos/rpi_ws281x/python/
sudo python3 examples/lights_off.py
ENDSSH
