# Run like
# $ ./benchit.sh | column -t > plot_benchmarks/benchmarks_depth
# or something...

echo "known_depth estimated_depth difference relative_difference "
#for known_depth in 1687; do

for known_depth in 233 319 482 639 1001 1416 1687; do
  hpm/hpm/hpm hpm/hpm/example-cam-params/myExampleCamParams.xml 25.84 hpm/hpm/test-images/ball_25_84_dist_${known_depth}_08_Z.png 2>&1 > output
  n_lines=`wc -l output | awk '{ print $1 }'`
  if [ 1 -ne $n_lines ];then
    echo "Error: found ${n_lines} lines of output. Expected 1. See the temporary file 'output' for details"
    exit
  fi
  estimated_depth=`sed -E 's/.+Camera: \([0-9][0-9]+?\.?[0-9]+?, [0-9][0-9]+?\.?[0-9]+?, (.+)\)mm/\1/g' output`
  difference=`bc -l <<< "${known_depth} - ${estimated_depth}"`
  relative_difference=`bc -l <<< "1-${known_depth}/${estimated_depth}"`
  echo "${known_depth} ${estimated_depth} ${difference} ${relative_difference}"
done
