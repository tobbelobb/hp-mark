# hp-mark ![hp-mark logo](./logo_small.png)

Measure Hangprinter externally

Current Hangprinters can only measure their own motor positions.
This is useful, but limited.
hp-mark is a separate solution for measuring a Hangprinter's
positions and orientations of anchors and effector.

# High-Level User-Story Dream
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

Comment on use case 2: By combining effector position data with the [auto-calibration-simulation-for-hangprinter](https://gitlab.com/tobben/auto-calibration-simulation-for-hangprinter/-/tree/hp_mark_adjusted), we might find perfect anchor positions without having the anchors in-image.

# History, as of Mar 31, 2021
This project was all about getting good pose estimations, for the first 6 months.
hp-mark was developed as a separate measurement system, with no Hangprinter-specific code or hardware.

We have now started manually executing Hangprinter use cases, like homing and anchor calibration.
See <a href="https://www.youtube.com/watch?v=o8oXp44mtUU">demo 0</a>,
See <a href="https://www.youtube.com/watch?v=m9qjuZQowCE">demo 1</a>, and
See <a href="https://www.youtube.com/watch?v=yRF-zevGHlQ">demo 2</a>.

Ahead of us now, is integration with RepRapFirmware, so that we can achieve automation.

# Status
We can estimate poses with one camera, stably and reliably. [Tweet](https://twitter.com/tobbelobb/status/1377256553665990659).

 - [x] Acquire hardware
 - [x] Calibrate camera
 - [x] Acquire training/benchmark images
 - [x] Calculate one 3D point from one marker
 - [x] Calculate _n_ single points from _n_ markers
 - [x] Calculate 6D pose from 6 points (solve perspective-6-point, or P6P problem)
 - [x] Acquire camera 6D pose (this includes defining our world coordinate system)
 - [x] Acquire effector 6D pose
 - [x] Detect all markers on 95% of training images
 - [x] Create a continuous stream of position measurements (video?)
 - [x] Get a statistical idea about size of error at the origin
 - [ ] Respond to RepRapFirmware/Duet request for position measurement

A checked box above means "good enough for now".

Nice-to-haves:

 - [ ] Take image ourselves upon request, don't rely on other programs to take image first
 - [ ] Get a statistical idea about size of precision and accuracy in the whole measurement volume
 - [ ] Integrate a second camera, to reduce error


# Equipment
 - Raspberry Pi 4, Model B, 2GB RAM
   * Processor (BCM2837) has an [Image Processor](https://en.wikipedia.org/wiki/Image_processor)
 - Arducam 8 MP Sony IMX219 camera module
 - Lens: M2504ZH05 Arducam lens
 - 32GB U3 SD card
 - Default recommended Raspberry Pi OS, 32-bit
 - OpenCV 4.4.0
 - EDLib for ellipse detection

# How To Clone This Repository

 - Clone with `git clone --recursive git@gitlab.com:tobben/hp-mark.git`. The `--recursive`
 - If you already did `git clone` without `--recursive`, do `git submodule init && git submodule update` to get submodule code right.

# How To Use This Repository

First calibrate your camera.
How to do that is described in [the README.md in camera-calibration directory](./camera-calibration/README.md).

Then compile `hpm`.

# hpm
hpm is the core part of hp-mark.
It is a program that reads data from the camera, and outputs a pose (three rotational values, three translational values).

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
 - python3 (not required for build & use)
 - black (not required for build & use)
 - scipy (not required for build & use)
 - numpy (not required for build & use)
 - raspistill (shading fix required if you don't use Picam. For why, see [here](https://www.arducam.com/docs/cameras-for-raspberry-pi/native-raspberry-pi-cameras/lens-shading-calibration/).)

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

There's also a few scripts that try to be helpful in
```
<path-to>/hp-mark/use/
```

# Remaining Challenges
 - The cameras' positions are estimated from images of known patterns. The results' accuracy are limited by errors in the markers and errors in the camera calibration values
 - We must measure and compensate for optical distortion

# Opportunities & Smaller Use Cases
 - After we've found 3 or more points individually, then we need to solve the perspective-n-point (PnP) problem.
   There's an interesting solver on its way into OpenCV that seems very good: [Added SQPnP algorithm to SolvePnP (2020)](https://github.com/opencv/opencv/pull/18371)
 - Distances between nozzle and markers may be measured by placing the nozzle on a marker, and letting hp-mark measure relative distances.
 - These distances are useful for line-collision-detector also.
 - We might need to control the image processor (to compensate distortion predictably, or for other tasks). An image processor can do [lots of things](https://webpages.uncc.edu/jfan/isp.pdf). But the Raspberry pi 4 and libcamera gives us the perfect tools for the job:
   * [raspberrypi.org page about libcamera](https://www.raspberrypi.org/documentation/linux/software/libcamera/)
   * [libcamera's own home page](http://www.libcamera.org/)
   * [Blog post announcing libcamera](https://www.raspberrypi.org/blog/an-open-source-camera-stack-for-raspberry-pi-using-libcamera/)

# Keywords
 camera localization, pose estimation, motion tracking, optical sensors, vision-based registration, marker-based tracking techniques, fiducial marker localization
