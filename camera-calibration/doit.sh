./make && \
./calibrate_camera_charuco2 --dictionary=16 \
                            --squares_x=16 \
                            --squares_y=11 \
                            --square_side_length=18.145 \
                            --marker_side_length=14.1 \
                            --images_list=./goodpics_list.xml \
                            --refind_strategy \
                            --detector_params=detector_params.yml \
                            --focal_length=2714.286 \
                            --grid_width=253.8 \
                            --verbose \
                            myCamParams.xml
