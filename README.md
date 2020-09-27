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

That user experience might be impossible to achieve, but let's get as close as we can.

# Use Cases by Priority
 0. Establish a coordinate system, with z-axis normal to the build plate
 1. The effector as a measurement device: Measure the effector's position and orientation
 2. Calibrate perfect anchor positions
 3. Measure Hangprinter's positional precision and accuracy
 4. Improve accuracy with static compensation matrix
 5. Detect print disasters
 6. Improve precision by dynamically compensating for measured errors

Comment on use case 2: By combining effector position data with the [auto-calibration-simulation-for-hangprinter](https://gitlab.com/tobben/auto-calibration-simulation-for-hangprinter/), we might find perfect anchor positions without hanving the anchors in-image.

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
 - [Pose estimation for augmented reality: a hands-on survey (2016)](https://hal.inria.fr/hal-01246370/document)
 - [Image-based camera localization: an overview (2018)](https://vciba.springeropen.com/articles/10.1186/s42492-018-0008-z)

### Square Tags
 - [Detection of ArUco Markers (2020)](https://docs.opencv.org/master/d5/dae/tutorial_aruco_detection.html)
   * OpenCV documentation. OpenCV is the most commonly used reference library in 2020.
 - [AprilTag 2: Efficient and robust fiducial detection (2016)](https://april.eecs.umich.edu/media/pdfs/wang2016iros.pdf)
   * April tags are the most common reference tags in 2020.
 - [Automatic generation and detection of highly reliable fiducial markers
under occlusion (2014)](https://code.ihub.org.cn/projects/641/repository/revisions/master/entry/readed/Automatic%20generation%20and%20detection%20of%20highly%20reliable%20fiducial%20markersnunder%20occlusion.pdf)
 - [Robust identification of fiducial markers in challenging conditions (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/320439756_Robust_identification_of_fiducial_markers_in_challenging_conditions/links/59e9fd810f7e9bfdeb6cb66c/Robust-identification-of-fiducial-markers-in-challenging-conditions.pdf)
 - [Speeded up detection of squared fiducial markers (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/325787310_Speeded_Up_Detection_of_Squared_Fiducial_Markers/links/5b346d19aca2720785ef8a84/Speeded-Up-Detection-of-Squared-Fiducial-Markers.pdf)
  - [Towards Low-Cost Indoor Localisation Using a Multi-camera System (2019)](https://www.iccs-meeting.org/archive/iccs2019/papers/115400136.pdf)
    * Practical project with a similar goal as HP Mark
    * Suggests using as big markers as possible
    * Suggests that averaging the results from multiple cameras works well

### Circular Tags & Video Work
 - [STag: A stable fiducial marker system (2019)](https://arxiv.org/pdf/1707.06292.pdf)
   * Establishes that we want circular tags for stability and robustness
 - [An Efficient Visual Fiducial Localisation System (2017)](http://eprints.lincoln.ac.uk/29678/1/ec4ebaef91e81085404ca74d9f87773b.pdf)
    * Establishes that we also want circular tags for computational efficiency.
    * Predicts where markers will be based on previous frames. Saves 99% of computation that way in an image series images were taken close in time (ie video) application.
  - [PDCAT: a framework for fast, robust, and occlusion resilient fiducial marker tracking (2020)](https://link.springer.com/article/10.1007/s11554-020-01010-w)
    * Also predicts marker position in video application, but doesn't mention _An Efficient Visual Fiducial Localisation System (2017)_
    * Bulids on top of a detection algorithm. Instead of helping the detection algorithm detect faster, it creates its own internal tracking position, which is faster to update, but less accurate than the detection algorithm. PDCAT acts like a subsystem that helps during fast-movement and/or partial occlusion of markers. If we feed PDCAT data back into detector algorithm for help/refinement, like in _An Efficient Visual Fiducial Localisation System (2017)_ we can get very fast, very robust, and very precise localization at the same time.
    * Suggests an architecture with four threads who share a stack of images:
      1. Image acquisition and storage thread
      2. Detection thread
      3. Compensation thread
      4. Tracking thread
    * Is able to predict and confirm marker position even when almost completely occluded. Regardless of marker type, just uses corners.

## Less Relevant but Still Interesting Opportunities
 - [Indoor Localization of Mobile Robots Through QR Code Detection and Dead Reckoning Data Fusion (2017)](https://scholar.google.com/scholar?q=Indoor%20Localization%20of%20Mobile%20Robots%20Through%20QR%20Code%20Detection%20and%20Dead%20Reckoning%20Data%20Fusion&btnG=Search&as_sdt=800000000001&as_sdtp=on)
   * Sensor fusion. It should be a goal of HP Mark to not have to use an IMU sensor (accelerometer) in addition to cameras
 - [TopoTag: A Robust and Scalable Topological Fiducial Marker System (2019)](https://arxiv.org/pdf/1908.01450.pdf)
   * Topological tags. Main benefit is that you can have many in each image. HP Mark will only need a few anyways.
 - [LFTag: A Scalable Visual Fiducial System with Low Spatial Frequency (2020)](https://arxiv.org/pdf/2006.00842.pdf)
   * Also topological tags
 - [BullsEye: High-Precision Fiducial Tracking for Table-based Tangible Interaction (2014)](https://www.klokmose.net/clemens/wp-content/uploads/2015/08/bullseye-author.pdf)
    * Solves an easier problem than ours: Tracking fiducials in a plane (2D)
    * Establishes that we can improve precision a lot by computing position from a grey scale image
    * GPU based tracking. This might be a bit over-kill for early tests, but might be just what HP Mark needs in the longer run.
    * Calibration of light that allows for computation on a greyscale image. Using grayscale improves precision and noise tolerance compared to black/white images. However, calibration of light relies on having a stable background image, which a running HP will not have. However, we can find estimate position based on black/white image, and refine that based on a grey scale image. Once found, we can know that some points of the tag should be white. With this assumption we can calibrate for background light after we've localized the tag.
    * An automated technique for optical distortion compensation
    * "If a fiducial is partially in a brighter lit area of a table, the position may be slightly offset towards the brighter lit area." Probably true for any fudicial, and a good argument for using several fudicials, not one single fiducial on the HP effector. Light will vary less across a smaller marker. We'll have to make a trade off on marker size anyways.
    * Briefly describes how we can create benchmark videos in Blender. This would be super useful for HP Mark to have.
 - [Affordable Infrared-Optical Pose-Tracking for Virtual and Augmented Reality (2007)](https://www.researchgate.net/profile/Hannes_Kaufmann/publication/228648906_Affordable_infrared-optical_pose-tracking_for_virtual_and_augmented_reality/links/0fcfd5092886b132ea000000/Affordable-infrared-optical-pose-tracking-for-virtual-and-augmented-reality.pdf)
    * Describes camera calibration quite well 



 # Keywords
 camera localization, pose estimation, motion tracking, optical sensors, vision-based registration, marker-based tracking techniques, fiducial marker localization

# Challenges
 - The cameras' positions, or at least distance from the origin, must be measured
 - We must compensate for optical distortion
 - We must place markers both on the effector (on-board) and on the build plate (off-board)
 - Off-board markers must define the global coordinate system. This breaks the Hangprinter's old system where the A-anchor defines the y-axis, and that the D-anchor defines the z-axis. So all anchor positions must be described with three (possibly non-zero) coordinates

# Opportunities & Smaller Use Cases
 - Distances between nozzle, pivot points, and on-board markers may be measured by placing markers on every point (or in the case of the nozzle, move it to one of the off-board markers), and letting hp-mark measure relative distances. This is useful for line-collision-detector, who needs those values.