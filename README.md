# hp-mark ![hp-mark logo](./logo_small.png)

Measure Hangprinter externally

Current Hangprinters can only measure their own motor positions.
This is useful, but limited.
hp-mark is a separate solution for measuring a Hangprinter's
positions and orientations of anchors and effector.

# High-Level Dream User Story
 1. Mount a computer-connected camera
 2. Point camera towards build area
 3. BAM! Hangprinter calibrates itself, and gets ready to start printing with fantastic accuracy & reliability

That user experience might be impossible to achieve, but let's get as close as we can.

# Use Cases by Priority
 0. Establish a coordinate system, with z-axis normal to the build plate (?)
 1. The effector as a measurement device: Measure the effector's position and orientation
 2. Calibrate perfect anchor positions
 3. Measure Hangprinter's positional precision and accuracy
 4. Improve accuracy with static compensation matrix
 5. Detect print disasters
 6. Improve precision by dynamically compensating for measured errors

Comment on use case 2: By combining effector position data with the [auto-calibration-simulation-for-hangprinter](https://gitlab.com/tobben/auto-calibration-simulation-for-hangprinter/), we might find perfect anchor positions without hanving the anchors in-image.

This project will be all about getting good tag localization first, in terms of accuracy and precision.

# Status
The camera is calibrated. [Tweet](https://twitter.com/tobbelobb/status/1317544500332515329)
We can not detect markers yet.

 - [x] Aquire hardware
 - [x] Calibrate camera
 - [x] Aquire training/benchmark images
 - [ ] Calculate one 3D point from one marker
 - [ ] Calculate _n_ single points from _n_ markers
 - [ ] Calculate 6D pose from _n_ points (solve perspective-n-point, or PnP problem)
 - [ ] Aquire camera 6D pose (this includes defining our world coordinate system)

A checked box above means "good enough for now".

# Equipment
 - Raspberry Pi 4, Model B, 2GB RAM
   * Processor (BCM2837) has an [Image Processor](https://en.wikipedia.org/wiki/Image_processor)
 - Picam module v 2.1
   * Pixel size 1.12 x 1.12 µm
   * Focal length 3.04 mm (?? My camera calibration says 2.89 mm, given 1.12 um pixel size. Not sure if I can trust the 3.04 mm value).
   * Horizontal field of view: 62.2 degrees
   * Vertical field of view: 48.8 degrees
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
 - [Tutorial: AprilTag marker detection (2020)](https://visp-doc.inria.fr/doxygen/visp-daily/tutorial-detection-apriltag.html)
   * The team who developes Visp seem to use AprilTags a lot, and they have made this great tutorial on how to use them with Visp.
 - [Automatic generation and detection of highly reliable fiducial markers
under occlusion (2014)](https://code.ihub.org.cn/projects/641/repository/revisions/master/entry/readed/Automatic%20generation%20and%20detection%20of%20highly%20reliable%20fiducial%20markersnunder%20occlusion.pdf)
 - [Robust identification of fiducial markers in challenging conditions (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/320439756_Robust_identification_of_fiducial_markers_in_challenging_conditions/links/59e9fd810f7e9bfdeb6cb66c/Robust-identification-of-fiducial-markers-in-challenging-conditions.pdf)
 - [Speeded up detection of squared fiducial markers (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/325787310_Speeded_Up_Detection_of_Squared_Fiducial_Markers/links/5b346d19aca2720785ef8a84/Speeded-Up-Detection-of-Squared-Fiducial-Markers.pdf)
  - [Towards Low-Cost Indoor Localisation Using a Multi-camera System (2019)](https://www.iccs-meeting.org/archive/iccs2019/papers/115400136.pdf)
    * Practical project with a similar goal as hp-mark
    * Suggests using as big markers as possible
    * Suggests that averaging the results from multiple cameras works well
  - [Robust 2 1/2D Visual Servoing of a Cable-Driven Parallel Robot Thanks to Trajectory Tracking (2020)](http://rainbow-doc.irisa.fr/pdf/2020_ral_zake.pdf)
    * Has a camera on the effector (or movement platform as some call it)
    * Improves the control of a cable driven robot with computer vision ("visual servoing")
    * Suggests using Lyapunov stability analysis for confirming the improvement
    * Manages to define a workspace within which control is stable
  - [Modeling and Vision-Based Control of Large-Dimension Cable-Driven Parallel Robots Using a Multiple-Camera Setup (2019)](https://hal-lirmm.ccsd.cnrs.fr/lirmm-02157768/document)
    * Again, very similar to hp-mark. Written by CoGiRo researchers. They have written papers that have helped the Hangprinter Project before, since their project is very similar (although bigger & more advanced).
    * Achieves a mean ~2cm accuracy across a 15x11x6 m large build volume.
    * Uses 3 cameras to detect pose (and 8 cameras for other things).
    * Uses a calibration object on the effector that looks like a game die. Top/bottom faces have 0 eyes. All other faces have 5 (white) eyes.
    * Uses Visp and goes into some detail about how they use it.
    * We might want to use as much of their work as possible as a starting point, although we should go into the details of all of their choices (tags, cameras, update frequencies, detection and tracking algorithms, etc...) first.
 - [Towards vision-based control of cable-driven parallel robots (2012)](https://hal.archives-ouvertes.fr/file/index/docid/691562/filename/Iros2011_ReelAx8_Accepted_Version_04juillet-1.pdf)
   * Earlier work by the CoGiRo team who motivated the 2019 paper mentioned above

### Circle and Ellipse Detection
 - OpenCV seems to be a bit behind on circle detection. All I can find is [Circle Hough Transform](https://en.wikipedia.org/wiki/Circle_Hough_Transform) which is slow and imprecise
 - [A Fast Operator for Detection and Precise Location of Distinct Points, Corners and Centres of Circular Features (1987)](https://cseweb.ucsd.edu/classes/sp02/cse252/foerstner/foerstner.pdf)
   * Much cited old paper, but I can't really grasp the maths of how circles should be located according to this paper.
 - [Circle Detection by Arc-Support Line Segments (2017)](https://alanlusun.github.io/files/ICIP%202017-Circle%20detection.pdf)
   * Code is published [here](https://github.com/AlanLuSun/Circle-detection)
   * Authors went on to generalize the algorithm for ellipses as well:   
- [Arc-support Line Segments Revisited: An Efficient High-quality Ellipse Detection (2019)](https://arxiv.org/pdf/1810.03243.pdf)
   * Code [here](https://github.com/AlanLuSun/High-quality-ellipse-detection)
- [Arc Adjacency Matrix-Based Fast Ellipse Detection (2020)](https://ieeexplore.ieee.org/document/8972900)
   * Code [here](https://github.com/Li-Zhaoxi/AAMED)
   * Claims to do almost exactly the same as _Arc-support Line Segments Revisited_, it extracts contours and constructs ellipses.
   * Also claims to be superior to all other state-of-the-art methods in all regards
- [An occlusion-resistant circle detector using inscribed triangles (2020)](https://www.researchgate.net/profile/Mingyang_Zhao5/publication/343560841_An_Occlusion-resistant_Circle_Detector_Using_Inscribed_Triangles/links/5f55c7fda6fdcc9879d306c6/An-Occlusion-resistant-Circle-Detector-Using-Inscribed-Triangles.pdf)
   * Also published in nice html [here](https://www.sciencedirect.com/science/article/pii/S0031320320303915?via%3Dihub)
   * Much the same again: Extract contour arcs, then group the arcs, then refine and verify that this is a circle/ellipse.
   * Uses tangent-triangles in both grouping and refining, and seems good at handling partial circles because of that
 - [Fitting a Circle to a Set Of Points](https://www.dtcenter.org/sites/default/files/community-code/met/docs/write-ups/circle_fit.pdf)
   * Just some maths, for reference
- [An efficient circle detector not relying on edge detection (2016)](https://www.sciencedirect.com/science/article/abs/pii/S0273117716300515)



### Circular Tags & Video Work
 - [Detection and Accurate Localization of Circular Fiducials under Highly Challenging Conditions (2016)](https://hal.archives-ouvertes.fr/hal-01420665/document)
   * Introduces CCTags
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
 - [Stereopi.com](https://stereopi.com/)
   * An open source community and hardware kit based around stereo computer vision with pi hardware.
   * A relevant article using stereopi: [Stereo Vision Applying OpenCV and Raspberry Pi (2019)](https://www.researchgate.net/publication/337644693_STEREO_VISION_APPLYING_OPENCV_AND_RASPBERRY_PI)
 - [Camera calibration method for solid spheres based on triangular primitives (2020)](https://www.sciencedirect.com/science/article/abs/pii/S0141635919308402)
   * Suggests that camera calibration also gets more stable if we use spheres instead of square markers printed on paper.
 - [Indoor Localization of Mobile Robots Through QR Code Detection and Dead Reckoning Data Fusion (2017)](https://scholar.google.com/scholar?q=Indoor%20Localization%20of%20Mobile%20Robots%20Through%20QR%20Code%20Detection%20and%20Dead%20Reckoning%20Data%20Fusion&btnG=Search&as_sdt=800000000001&as_sdtp=on)
   * Sensor fusion. It should be a goal of hp-mark to not have to use an IMU sensor (accelerometer) in addition to cameras
 - [TopoTag: A Robust and Scalable Topological Fiducial Marker System (2019)](https://arxiv.org/pdf/1908.01450.pdf)
   * Topological tags. Main benefit is that you can have many in each image. hp-mark will only need a few anyways.
 - [LFTag: A Scalable Visual Fiducial System with Low Spatial Frequency (2020)](https://arxiv.org/pdf/2006.00842.pdf)
   * Also topological tags
 - [BullsEye: High-Precision Fiducial Tracking for Table-based Tangible Interaction (2014)](https://www.klokmose.net/clemens/wp-content/uploads/2015/08/bullseye-author.pdf)
    * Solves an easier problem than ours: Tracking fiducials in a plane (2D)
    * Establishes that we can improve precision a lot by computing position from a grey scale image compared to a binary (black and white) one.
    * GPU based tracking. This might be a bit over-kill for early tests, but might be just what hp-mark needs in the longer run.
    * Calibration of light that allows for computation on a greyscale image. Using grayscale improves precision and noise tolerance compared to black/white images. However, calibration of light relies on having a stable background image, which a running HP will not have. However, we can find estimate position based on black/white image, and refine that based on a grey scale image. Once found, we can know that some points of the tag should be white. With this assumption we can calibrate for background light after we've localized the tag.
    * An automated technique for optical distortion compensation
    * "If a fiducial is partially in a brighter lit area of a table, the position may be slightly offset towards the brighter lit area." Probably true for any fudicial, and a good argument for using several fudicials, not one single fiducial on the HP effector. Light will vary less across a smaller marker. We'll have to make a trade off on marker size anyways.
    * Briefly describes how we can create benchmark videos in Blender. This would be super useful for hp-mark to have.
 - [Affordable Infrared-Optical Pose-Tracking for Virtual and Augmented Reality (2007)](https://www.researchgate.net/profile/Hannes_Kaufmann/publication/228648906_Affordable_infrared-optical_pose-tracking_for_virtual_and_augmented_reality/links/0fcfd5092886b132ea000000/Affordable-infrared-optical-pose-tracking-for-virtual-and-augmented-reality.pdf)
    * Describes camera calibration quite well
 - [Time-of-Flight Cameras in Computer Graphics (2010)](https://www.cg.informatik.uni-siegen.de/data/www.cg.informatik.uni-siegen.de/data/Publications/2010/kolb10survey.pdf)
   * A great (although a bit outdated) introduction to challenges for Time-of-flight cameras (like Lidars)
   * There are big hurdles to be overcome, like low resolution and high price
   * The promise for the future is also enormous
   * There is a race between RGB cameras and time-of-flight cameras. Both want to be the best solution for pose estimation. I can easily imagine time-of-flight winning in the long run, and sensor fusion between them helping ToF to become relevant earlier (see for example [this (2016)](https://past.date-conference.com/proceedings-archive/2016/pdf/0446.pdf)).
 - [High-performance Indoor Positioning and Pose Estimation with Time-of-Flight 3D Imaging (2018)](https://www.researchgate.net/profile/Hannes_Plank/publication/321260313_High-performance_indoor_positioning_and_pose_estimation_with_time-of-flight_3D_imaging/links/5a840591a6fdcc6f3eb3338f/High-performance-indoor-positioning-and-pose-estimation-with-time-of-flight-3D-imaging.pdf)
   * Efforts for getting depth images at higher frequencies. Author Hannes Plank does a lot of work on ToF
 - [Design, stiffness analysis and experimental study of a cable-driven parallel 3D printer (2019)](https://www.sciencedirect.com/science/article/abs/pii/S0094114X18315568)
   * Somebody designed a Hangprinter with a spring instead of motorized D-axis
   * They used a very expensive optical tracker (V120:Trio, ca $3000) system to check accuracy. The system uses six small spheres as markers: three on the build plate and three on the effector. After looking at products on optitrack.com, it seems like they use a lot of these ca 1 cm diameter grey spheres as markers, for all kinds of different tracking problems. I also see only greyscale images, no time-of-flight sensors (but they might be there)

# Practical Know How
 - [Fixed camera setup for object localization and measurement](https://pgaleone.eu/computer-vision/2019/01/18/camera-setup-measurement/)
 - [Install OpenCV 4.4.0 on Raspberry Pi 4 (visited Oct 2020)](https://qengineering.eu/install-opencv-4.4-on-raspberry-pi-4.html)
 - [hp-mark camera calibration (2020)](./camera-calibration)

# Keywords
 camera localization, pose estimation, motion tracking, optical sensors, vision-based registration, marker-based tracking techniques, fiducial marker localization

# Challenges
 - The cameras' positions, or at least distance from the origin, must be known
   * It can be hand measured. This is laborious but safe
   * It can also be estimated from images of known patterns. The results' accuracy will be limited by errors in the markers and errors in the camera calibration values.
 - We must compensate for optical distortion
 - We might need to control the image processor (to compensate distortion predictably, or for other tasks). An image processor can do [lots of things](https://webpages.uncc.edu/jfan/isp.pdf). But the Raspberry pi 4 and libcamera gives us the perfect tools for the job:
   * [raspberrypi.org page about libcamera](https://www.raspberrypi.org/documentation/linux/software/libcamera/)
   * [libcamera's own home page](http://www.libcamera.org/)
   * [Blog post announcing libcamera](https://www.raspberrypi.org/blog/an-open-source-camera-stack-for-raspberry-pi-using-libcamera/)
 - We must place markers both on the effector (on-board) and on the build plate (off-board)
 - Off-board markers must define the global coordinate system. This breaks the Hangprinter's old system where the A-anchor defines the y-axis, and that the D-anchor defines the z-axis. So all anchor positions must be described with three (possibly non-zero) coordinates (edit 20 Oct 2020: I'm not sure that we should use off-board markers anymore.)

# Opportunities & Smaller Use Cases
 - Could spherical 3d fiducials simplify the image analysis? Their radius in pixels should translate directly to a depth. Its the simplest shape to reason about anyways. I should find some first principles based on spherical fiducials.
 - After we've found 3 or more points individually, then we need to solve the perspective-n-point (PnP) problem.
   There's an interesting solver on its way into OpenCV that seems very good: [Added SQPnP algorithm to SolvePnP (2020)](https://github.com/opencv/opencv/pull/18371)
 - Distances between nozzle, pivot points, and on-board markers may be measured by placing markers on every point (or in the case of the nozzle, move it to one of the off-board markers), and letting hp-mark measure relative distances. This is useful for line-collision-detector, who needs those values.

# How To Clone This Repository

 - Clone with `git clone --recursive git@gitlab.com:tobben/hp-mark.git`. The `--recursive`
 - If you already did `git clone` without `--recursive`, do `git submodule init && git submodule update` to get submodule code right.

# How To Use This Repository

First calibrate your camera.
How to do that is described in [the README.md in camera-calibration directory](./camera-calibration/README.md).

Then compile `hpm`.

# hpm
hpm is the core part of hp-mark.
It a is (planned to be) a program that reads data from the camera, and outputs position data of your marker(s).

## hpm Dependencies
This repo will (for now) assume that a number of dependencies are already installed by the user.
 - OpenCV 4.4.0 or later
 - g++ version 10 or later
 - build2 version 0.13.0 or later
 - clang++ version 10 or later (not required for build & use)
 - clang-tidy version 10 or later (not required for build & use)
 - clang-format version 10 or later (not required for build & use)
 - compiledb (not required for build & use)
 - shfmt (not required for build & use)

## hpm Target Hardware
We will strive to provide how-tos for installing these on the Raspberry Pi 4 with 32-bit Raspberry Pi OS on it.
How-tos will be put in the `doc/` directory as they are created.

Even better would be to provide the complete Raspberry Pi OS image for users, with all dependencies already there.

## hpm Ubuntu Development Environment
Since the Raspberry Pi 4 is slower than my Ubuntu laptop and desktop, most development will happen on those machines.
We will strive to post how-tos about how to install dependencies under Ubuntu as well.

### Why Are Some Dependencies Not Required for hpm Build & Use?
Scripts `tidy.sh`, `make-compilation-database.sh`, `format.sh` etc are there to softly enforce some coding quality and standards.
It you're not going to change the code anyways, then you don't need the scripts nor their dependencies.

## hpm How To Build
Before building `hpm` with build2, its recommended to create a build configuration.
No pre-configured build configuration is shipped with this project, and build2's default configuration works poorly with hpm.

### If You're a User
```
cd <path-to>/hp-mark/hpm
bdep init --config-create ../my-build-dir @user cc config.cxx=g++-10
```
This creates a build2 config, gives it the location `../my-build-dir`, the name `@user`, and the compiler `g++-10`.
Compile with
```
b
```

### If You're a Developer
Create a configuration with some more compiler flags than the user:
```
cd <path-to>/hp-mark/hpm
#in < path - to > / hp - mark / hpm
bdep init --config-create ../my-advanced-config @developer cc config.cxx=g++-10 config.cxx.coptions="-g -Wall -Wextra -Wold-style-cast -Wnon-virtual-dtor -pedantic -Wcast-align -Wunused -Woverloaded-virtual -Wpedantic -Wconversion -Wsign-conversion -Wmisleading-indentation -Wnull-dereference -Wdouble-promotion -Werror -O2 -march=native"
```
You can edit your personal or compiler specific flags later, in `<path-to>/hp-mark/my-advanced-config/build/config.build`.
Some example flags for reference can be seen in `<path-to>/hp-mark/hpm-gcc/build/config.build`.

Compile with
```
b test
```
which will build and test using your default build config.

Symlinks to executables end up in `<path-to>/hp-mark/hpm/hpm/`.
The executables themselves, as well as build artifacts, end up in `../my-build-dir/hpm/hpm/` or `../my-advanced-config/hpm/hpm/`, depending on which build you updated.

Create as many configs as you want.
One that cross compiles for the Raspberry Pi 4 might be particularly useful in the later stages of this project, when build times get noticeable.

You can see all your configs, and which of them is the default with
```
bdep config list
```
bdep is a very flexible and useful command. See its documentation [here](https://build2.org/bdep/doc/bdep-config.xhtml).

I use [some own notes](https://gitlab.com/hangprinter/linc/-/blob/master/README.md) for remembering build2 commands.


## How To Run
Your executable should tell you how it wants to be used.
Ask it like this:
```
<path-to>/hp-mark/hpm/hpm/hpm
```
