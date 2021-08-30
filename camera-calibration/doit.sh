./make &&
	./calibrate_camera_charucoRO --dictionary=16 \
		--squares_x=16 \
		--squares_y=11 \
		--square_side_length=18.145 \
		--marker_side_length=14.1 \
		--images_list=./pics_list.xml \
		--refind_strategy \
		--detector_params=detector_params.yml \
		--grid_width=253.8 \
		--verbose \
		myCamParams.xml
