# You can use the shutter and ISO options to adapt for quite a dark room
# raspistill -v --quality 100 --keypress --encoding png -o camera_calib_%04d.png --width 3280 --height 2464 --shutter 400000 --ISO 50
#raspistill -v --quality 100 --keypress --encoding png -o camera_calib_%04d.png --width 3280 --height 2464

#pngpics
#raspistill --keypress --quality 100 --encoding png -o camera_calib_%04d.png --width 3280 --height 2464 --shutter 89000 --ISO 50 --awb greyworld -fs 17 -v
#goodpics
raspistill --keypress --quality 100 --encoding png -o camera_calib_%02d.png --width 3280 --height 2464 --shutter 65000 --ISO 50 -fs 0 -v
