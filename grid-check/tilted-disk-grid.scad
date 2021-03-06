// Use command line to create renders.
// For example

// openscad --camera 0,0,0,0,0,0,2000 --imgsize 15360,8058 --colorscheme Nature --projection perspective -o grid-blue-2000.png sphere-grid.scad


$fn=2000;

squareWidth = 100;
gridWidthx = 7;
gridWidthy = 4;
//$vpt=[0,0,0];
//$vpr=[0,0,0];
//$vpd=2000;

for (nx = [-gridWidthx:gridWidthx])
  for (ny = [-gridWidthy:gridWidthy])
    translate([nx*squareWidth, ny*squareWidth, 0])
      color([1,1,1])
        rotate([0,-45,0])
          cylinder(d=70, h=0.01);

