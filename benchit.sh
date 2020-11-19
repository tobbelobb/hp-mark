# Run like
# $ ./benchit.sh | column -t > plot_benchmarks/benchmarks_depth
# or something...

echo "known_depth estimated_depth difference relative_difference "
#for known_depth in 1687; do
total_difference=0
total_relative_difference=0
iterations=0

for known_depth in 233 319 482 639 1001 1416 1687; do
	hpm/hpm/hpm hpm/hpm/example-cam-params/myExampleCamParams.xml 25.84 hpm/hpm/test-images/ball_25_84_dist_${known_depth}_08_Z.png 2>&1 >output
	n_lines=$(wc -l output | awk '{ print $1 }')
	if [ 1 -ne $n_lines ]; then
		echo "Error: found ${n_lines} lines of output. Expected 1. See the temporary file 'output' for details"
		exit 1
	fi
	estimated_depth=$(sed -E 's/.*\[-?[0-9][0-9]+?\.?[0-9]+?, -?[0-9][0-9]+?\.?[0-9]+?, (.+)\]mm/\1/g' output)
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
