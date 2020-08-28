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
This project is being planned.

# Roadmap
Let's start with point 1 and see how far we get.

We plan to use cameras and aruco tags, similar to [this](https://github.com/fredrudolf/hangprinter-computer-vision-calibration).