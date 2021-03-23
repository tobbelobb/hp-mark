SERIES_NAME="3YIsz"
HPM="../hpm/hpm/hpm ../hpm/hpm/example-cam-params/myExampleCamParams.xml ../hpm/hpm/example-marker-params/my-marker-params.xml ./images/"
MAX_NUM=81

let "INC=1"
PADDED_COUNT=""
while [ ${INC} -le ${MAX_NUM} ]; do
	printf -v PADDED_COUNT "%04d" ${INC}
  echo -n "${PADDED_COUNT} "
  ${HPM}${SERIES_NAME}/${PADDED_COUNT}.jpg
	let "INC=INC+1"
done

# SET 2
# ${HPM}3YIsz/0003.jpg
# ${HPM}3YIsz/0007.jpg
# ${HPM}3YIsz/0009.jpg
# ${HPM}3YIsz/0026.jpg
# ${HPM}3YIsz/0030.jpg
# ${HPM}3YIsz/0040.jpg
# ${HPM}3YIsz/0045.jpg
# ${HPM}3YIsz/0048.jpg
# ${HPM}3YIsz/0051.jpg
# ${HPM}3YIsz/0055.jpg
# ${HPM}3YIsz/0058.jpg
# ${HPM}3YIsz/0061.jpg
# ${HPM}3YIsz/0064.jpg
# ${HPM}3YIsz/0068.jpg
