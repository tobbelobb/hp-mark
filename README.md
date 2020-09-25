# HP Mark

Measure Hangprinter externally

Current Hangprinters can only measure their own motor positions.
This is useful, but limited.
HP Mark is a separate solution for measuring a Hangprinter's
positions and orientations of anchors and effector.

# High-Level Dream User Story
 1. Mount a computer-connected camera
 2. Point camera towards build area
 3. BAM! Hangprinter calibrates itself, and gets ready to start printing with fantastic accuracy & reliability 

A user experience and performance might be impossible to achieve.
We'll try and get as close to that as we can, and remain aware of any discrepancies.

# Use Cases by Priority
 0. Establish a coordinate system, with z-axis normal to the build plate
 1. The effector as a measurement device: Measure the effector's position and orientation
 2. Calibrate perfect anchor positions
 3. Measure Hangprinter's positional precision and accuracy
 4. Improve accuracy with static compensation matrix
 5. Detect print disasters
 6. Improve precision by dynamically compensating for measured errors

Comment on use case 2: By combining effector position data with the [auto-calibration-simulation-for-hangprinter](https://gitlab.com/tobben/auto-calibration-simulation-for-hangprinter/), we might find perfect anchor positions without hanving the anchors in-image.

I plan to use cameras and aruco tags, similar to [this](https://github.com/fredrudolf/hangprinter-computer-vision-calibration).

This project will be all about getting good tag localization first, in terms of accuracy and precision.

# Status
I've just started working on this project. [Tweet](https://twitter.com/tobbelobb/status/1309108246850961409).

# Equipment
 - Raspberry Pi 4, Model B, 2GB RAM
 - Picam module v 2.1
 - 32GB U3 SD card
 - Default recommended Raspberry Pi OS, 32-bit
 - Library choice OpenCV and/or ViSP and/or Vuforia has not been decided

# Reading List
 - [Motion tracking: No silver bullet, but a respectable arsenal (2002)](https://my.eng.utah.edu/~cs6360/Readings/cga02_welch_tracking.pdf)
 - [A Comprehensive Survey of Indoor Localization Methods Based on Computer Vision (2020)](https://www.mdpi.com/1424-8220/20/9/2641/pdf)
 - [Indoor Localization of Mobile Robots Through QR Code Detection and Dead Reckoning Data Fusion (2017)](https://scholar.google.com/scholar?q=Indoor%20Localization%20of%20Mobile%20Robots%20Through%20QR%20Code%20Detection%20and%20Dead%20Reckoning%20Data%20Fusion&btnG=Search&as_sdt=800000000001&as_sdtp=on)
 - [Pose estimation for augmented reality: a hands-on survey (2016)](https://hal.inria.fr/hal-01246370/document)
 - [Image-based camera localization: an overview (2018)](https://vciba.springeropen.com/articles/10.1186/s42492-018-0008-z)
 - [Detection of ArUco Markers (2020)](https://docs.opencv.org/master/d5/dae/tutorial_aruco_detection.html)
 - [Automatic generation and detection of highly reliable fiducial markers
under occlusion (2014)](https://code.ihub.org.cn/projects/641/repository/revisions/master/entry/readed/Automatic%20generation%20and%20detection%20of%20highly%20reliable%20fiducial%20markersnunder%20occlusion.pdf)
 - [Robust identification of fiducial markers in challenging conditions (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/320439756_Robust_identification_of_fiducial_markers_in_challenging_conditions/links/59e9fd810f7e9bfdeb6cb66c/Robust-identification-of-fiducial-markers-in-challenging-conditions.pdf)
 - [Speeded up detection of squared fiducial markers (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/325787310_Speeded_Up_Detection_of_Squared_Fiducial_Markers/links/5b346d19aca2720785ef8a84/Speeded-Up-Detection-of-Squared-Fiducial-Markers.pdf)
 - [An Efficient Visual Fiducial Localisation System (2017)](http://eprints.lincoln.ac.uk/29678/1/ec4ebaef91e81085404ca74d9f87773b.pdf)
 - [STag: A stable fiducial marker system (2019)](https://arxiv.org/pdf/1707.06292.pdf)
 - [Assessment of Optical Markers for On-Board Autonomous Localization of eVTOLs during Landing (2020)](http://icrat.org/ICRAT/seminarContent/2020/papers/ICRAT2020_paper_20.pdf)

 # Keywords
 camera localization, pose estimation, motion tracking, optical sensors, vision-based registration, marker-based tracking techniques

# Challenges
 - The cameras' positions, or at least distance from the origin, must be measured
 - We must place markers both on the effector (on-board) and on the build plate (off-board)
 - Off-board markers must define the global coordinate system. This breaks the Hangprinter's old system where the A-anchor defines the y-axis, and that the D-anchor defines the z-axis. So all anchor positions must be described with three (possibly non-zero) coordinates

# Opportunities & Smaller Use Cases
 - Distances between nozzle, pivot points, and on-board markers may be measured by placing markers on every point (or in the case of the nozzle, move it to one of the off-board markers), and letting hp-mark measure relative distances. This is useful for line-collision-detector, who needs those values.