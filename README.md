# HP Mark

Measure Hangprinter externally

Current Hangprinters can only measure their own motor positions.
This is useful, but limited.
HP Mark is a separate solution for measuring a Hangprinter's
positions and orientations of anchors and effector.
We could use this data to:
 1. Calibrate perfect anchor positions
 2. Measure Hangprinter precision and accuracy
 3. Improve accuracy with static compensation matrix
 4. Detect print disasters
 5. Improve precision by dynamically compensating for measured errors

# Status
I've just started working on this project. [Tweet](https://twitter.com/tobbelobb/status/1309108246850961409).

# Roadmap
Let's start with point 1 and see how far we get.

We plan to use cameras and aruco tags, similar to [this](https://github.com/fredrudolf/hangprinter-computer-vision-calibration).

# Equipment
 - Raspberry Pi 4, Model B, 2GB RAM
 - Picam module v 2.1
 - 32GB U3 SD card
 - Default recommended Raspberry Pi OS, 32-bit
 - Library choice OpenCV and/or ViSP and/or Vuforia has not been decided

# Reading List
 - [Pose estimation for augmented reality: a hands-on survey (2016)](https://hal.inria.fr/hal-01246370/document)
 - [Detection of ArUco Markers (2020)](https://docs.opencv.org/master/d5/dae/tutorial_aruco_detection.html)
 - [Automatic generation and detection of highly reliable fiducial markers
under occlusion (2014)](https://code.ihub.org.cn/projects/641/repository/revisions/master/entry/readed/Automatic%20generation%20and%20detection%20of%20highly%20reliable%20fiducial%20markersnunder%20occlusion.pdf)
 - [Robust identification of fiducial markers in challenging conditions (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/320439756_Robust_identification_of_fiducial_markers_in_challenging_conditions/links/59e9fd810f7e9bfdeb6cb66c/Robust-identification-of-fiducial-markers-in-challenging-conditions.pdf)
 - [Speeded up detection of squared fiducial markers (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/325787310_Speeded_Up_Detection_of_Squared_Fiducial_Markers/links/5b346d19aca2720785ef8a84/Speeded-Up-Detection-of-Squared-Fiducial-Markers.pdf)

 # Keywords
 camera localization, pose estimation, motion tracking, optical sensors, vision-based registration, marker-based tracking techniques


