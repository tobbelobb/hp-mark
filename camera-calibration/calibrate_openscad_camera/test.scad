// This script can be used to figure out the focal length
// that OpenScad will use when generating
// 2560 px wide generated images

// Generate an image with
// openscad --camera 0,0,0,90,0,0,3377.17 --imgsize 2560,1343 --colorscheme Nature -o 3377.17.png test.scad
// And see if the cube fills the image in the left/right direction or the top/down direction
// Treat the vertical direction separately from the horizontal direction.
// They will experience different truncation errors but land on the same mean value

width = 2560;
height = 1343;

translate([-width/2,0,-height/2])
cube([width,1,height]);
