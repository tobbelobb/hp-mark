#!/usr/bin/env bash

# Run like
# $ ./single-markers-real-images.sh | column -t > plot_benchmarks/benchmarks_depth
# or something...

set -o errexit
set -o pipefail

echo "known_depth estimated_depth difference relative_difference "
total_difference=0
total_relative_difference=0
iterations=0

for known_depth in 233 319 482 639 1001 1416 1687; do
	hpm/hpm/hpm ./benchitCamParams.xml ./benchitMarkerParams.xml hpm/hpm/test-images/ball_25_84_dist_${known_depth}_08_Z.png 2>&1 >output
	n_lines=$(wc -l output | awk '{ print $1 }')
	if [ 2 -ne $n_lines ]; then
		echo "Error: found ${n_lines} lines of output. Expected 2. See the temporary file 'output' for details"
		exit 1
	fi
	estimated_depth=$(head -2 output | tail -1 | sed -E 's/.*\[-?[0-9][0-9]+?\.?[0-9]+?, -?[0-9][0-9]+?\.?[0-9]+?, (.+)\],?/\1/g')
	difference=$(bc -l <<<"${known_depth} - ${estimated_depth}")
	relative_difference=$(bc -l <<<"1-${known_depth}/${estimated_depth}")
	echo "${known_depth} ${estimated_depth} ${difference} ${relative_difference}"
	total_difference=$(bc -l <<<"define abs(i) {
                      if (i < 0) return (-i)
                      return (i)
                    }
                    ${total_difference} + abs(${difference})")
	total_relative_difference=$(bc -l <<<"define abs(i) {
                               if (i < 0) return (-i)
                               return (i)
                             }
                             ${total_relative_difference} + abs(${relative_difference})")
	iterations=$(bc -l <<<"${iterations}+1")
done
mean_difference=$(bc -l <<<"${total_difference} / ${iterations}")
mean_relative_difference=$(bc -l <<<"${total_relative_difference} / ${iterations}")
echo ""
echo "total_difference total_relative_difference mean_difference mean_relative_difference"
echo "${total_difference} ${total_relative_difference} ${mean_difference} ${mean_relative_difference}"

./hpm example-cam-params/openscadHandCodedCamParamsRotX30.xml example-marker-params/elevated-marker-params.xml test-images/generated_benchmark_nr6_32_elevated_150p43_0_0_0_30_0_0_1500.png 2>&1 output2
n_lines=$(wc -l output2 | awk '{ print $1 }')
if [ 3 -ne $n_lines ]; then
	echo "Error: found ${n_lines} lines of output. Expected 3. See the temporary file 'output2' for details"
	exit 1
fi
