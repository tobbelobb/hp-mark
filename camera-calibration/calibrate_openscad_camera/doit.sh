# Dump some calibration images
openscad --camera -2.39,-66.23,37.04,49.9,0,359.6,2264.24      --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00000.png scene.scad
openscad --camera  37.14,-122.39,-54.19,52.7,0,29,2296         --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00001.png scene.scad
openscad --camera 136.35,12.34,-81.12,53.4,0,60.5,2557         --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00002.png scene.scad
openscad --camera 107.45,12.39,-49.25,46.4,0,90.6,2547.78      --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00003.png scene.scad
openscad --camera 91.81,65.31,-63.52,47.8,0,120.7,2886         --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00004.png scene.scad
openscad --camera 80.53,52.77,-48.47,42.9,0,154.3,2800         --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00005.png scene.scad
openscad --camera -7.27,54.79,-48.38,34.5,0,180.2,2215         --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00006.png scene.scad
openscad --camera 50.34,79.79,-78.75,50.6,0,196.3,2215         --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00007.png scene.scad
openscad --camera -94.89,-6.9,-120.59,52,0,221.5,2673          --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00008.png scene.scad
openscad --camera -75.61,-43.08,-92.93,48.5,0,261.4,2673       --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00009.png scene.scad
openscad --camera -73.7,-38.31,-89.82,49.2,0,279.6,2673        --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00010.png scene.scad
openscad --camera -90.66,-35.63,-99.43,51.3,0,323.7,2592       --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00011.png scene.scad
openscad --camera -9.11,4.04,-79.34,301.60,0.00,180.40,2407.58 --imgsize 2560,1343 --colorscheme Nature --projection p -o frame00012.png scene.scad

pushd .. && \
./make && \
popd && \
../calibrate_camera_charucoRO --dictionary=16 \
                             --squares_x=16 \
                             --squares_y=11 \
                             --square_side_length=90.0 \
                             --marker_side_length=70.0 \
                             --images_list=./pics_list.xml \
                             --refind_strategy \
                             --detector_params=../detector_params.yml \
                             --grid_width=1260.0 \
                             --verbose \
                             openscadCamParams.xml
