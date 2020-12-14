#!/usr/bin/env bash

IMAGE="./hpm/hpm/test-images/generated_benchmark_nr6_32_elevated_150p43_0_0_0_30_0_0_1500.png"

OUT=$(./hpm/hpm/hpm ./hpm/hpm/example-cam-params/openscadHandCodedCamParamsRotX30.xml ./hpm/hpm/example-marker-params/elevated-marker-params.xml ${IMAGE} 2>&1)

echo ${OUT} > output2
n_lines=$(wc -l output2 | awk '{ print $1 }')
if [ 1 -ne $n_lines ]; then
	echo "Error: found ${n_lines} lines of output. Expected 1. See the temporary file 'output2' for details"
	exit 1
fi
error=$(octave --eval "norm(${OUT})" | sed -E 's/ans = (.+)/\1/g')
echo "Error in result from image ${IMAGE}:"
echo "${error} mm"
