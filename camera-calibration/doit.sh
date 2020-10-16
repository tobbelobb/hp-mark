./make && \
./calibrate_camera_charuco2 --dictionary=16 \
                            --squares_x=16 \
                            --squares_y=11 \
                            --marker_side_length=14.117 \
                            --square_side_length=18.15 \
                            --images_list=./pics_list.xml \
                            --refind_strategy \
                            --detector_params=detector_params.yml \
                            myCamParams.xml
