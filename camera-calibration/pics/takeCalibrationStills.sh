# You can use the shutter and ISO options to adapt for quite a dark room
# raspistill -v --quality 100 --keypress --encoding png -o camera_calib_%04d.png --width 3280 --height 2464 --shutter 400000 --ISO 50
raspistill -v --quality 100 --keypress --encoding png -o camera_calib_%04d.png --width 3280 --height 2464
