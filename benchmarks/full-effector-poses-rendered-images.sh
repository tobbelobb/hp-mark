#!/usr/bin/env bash

set -o errexit
set -o pipefail

readonly BINPATH="$(dirname "$0")"
readonly HPMPATH="${BINPATH}/../hpm"
readonly TMPDIR="${BINPATH}/tmp"
mkdir -p "${TMPDIR}/"
readonly TMPFILE=$(mktemp -p "${TMPDIR}/" XXXXXXXXXX)

# Rebuild hpm binary
pushd "${HPMPATH}" >/dev/null
b
popd >/dev/null

readonly IMAGE="${HPMPATH}/hpm/test-images/generated_benchmark_nr6_32_elevated_150p43_0_0_0_30_0_0_1500.png"
readonly COMMAND="${HPMPATH}/hpm/hpm ${HPMPATH}/hpm/example-cam-params/openscadHandCodedCamParamsRotX30.xml ${BINPATH}/cam-params/elevated-marker-params-openscad.xml ${IMAGE}"
readonly OUT=$(${COMMAND} 2>&1 | tee ${TMPFILE})

n_lines=$(wc -l ${TMPFILE} | awk '{ print $1 }')
if [ 1 -ne $n_lines ]; then
	echo "Error: found ${n_lines} lines of output. Expected 1. See the temporary file ${TMPFILE} for details"
	exit 1
fi
error=$(octave --eval "norm(${OUT::-1})" | sed -E 's/ans = (.+)/\1/g')
echo "Analyzed image ${IMAGE}:"
echo "Found a position ${error} mm from the origin"
