# How To Calibrate PiCam v2 for HP Mark

Print the charuco board pdf as large as you can.
I will assume you've printed it on A4 paper to the edges.
That gives 18mm wide squares and 14mm wide aruco tags.
Tape/glue your charuco board down as flat and straight as possible.

Go into the pics directory and take a look at the example calibration
images that I've left there.
Next remove all those images.

```
cd pics
rm camera*
```

Then take your own pics.
```
./takeCalibrationStills.sh
```
Press Enter to take a picture, press X followed by enter when you're done.
Look through the images and remove those who don't show the charuco board clearly.

Look into the `pics_list.xml`.
Add/remove images.

Compile the program
```
./make
```

Run the program in test mode
```
./calibrate_camera_charuco2 -d=16 -w=16 -h=9 --ml=0.014 --sl=0.018 -l=./pics_list.xml --test myCamParams.xml
```
Check that your aruco tags get detected.

Run the program in after-check mode
```
./calibrate_camera_charuco2 -d=16 -w=16 -h=9 --ml=0.014 --sl=0.018 -l=./pics_list.xml --sc myCamParams.xml
```
Check that the edges are straight.
An output file `myCamParams.xml` should have been created, it should now contain the intrinsic and extrinsic parameters
for your PiCam v2.
