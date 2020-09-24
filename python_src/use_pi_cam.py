from picamera import PiCamera
from time import sleep

camera = PiCamera()

camera.start_preview()
for effect in camera.IMAGE_EFFECTS:
  camera.image_effect = effect
  camera.annotate_text = "Effect: %s" % effect
  sleep(5) # Time for camera to adjust its light levels
  
camera.stop_preview()
#camera.resolution = (3280, 2464)
