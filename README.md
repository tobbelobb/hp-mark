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

# Reading List
[Automatic generation and detection of highly reliable fiducial markers
under occlusion (2014)](https://code.ihub.org.cn/projects/641/repository/revisions/master/entry/readed/Automatic%20generation%20and%20detection%20of%20highly%20reliable%20fiducial%20markersnunder%20occlusion.pdf)
[Robust identification of fiducial markers in challenging conditions (2018)](https://www.researchgate.net/profile/Rafael_Munoz-Salinas/publication/320439756_Robust_identification_of_fiducial_markers_in_challenging_conditions/links/59e9fd810f7e9bfdeb6cb66c/Robust-identification-of-fiducial-markers-in-challenging-conditions.pdf)

