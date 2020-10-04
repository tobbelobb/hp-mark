use <revolve2.scad>

screw_length=11;
screw_r=4.5;

//!intersection(){
//translate([0,0,-screw_length/2])
//screw();
//top_cap();
//}
translate([0,0,-screw_length/2])
!screw();
module screw() {

  //// A sinusoidal profile function...
  //period = 3;
  //function prof_sin(z) = [z, 10+sin(z*360/period)];
  //// ...which becomes a profile vector with the help of linspace
  //sin_prof = [for (z=linspace(start=0, stop=period, n=15)) prof_sin(z)];
  //revolve( sin_prof, length=30, nthreads=2, $fn=30);

  revolve(profile = [[0, screw_r-0.5], [0.6, screw_r], [1.2, screw_r-0.5]], length=screw_length, nthreads=2, $fn=40);
}

sphere_r = 15;
sphere_wall_th = 1.2;
cube_w = 2*sphere_r+2;

//// Inspect section cut
//!difference() {
//  top_cap();
//  rotate([0,0,45])
//  translate([-30,0,-1])
//  cube(60);
//}
top_cap();
module top_cap() {
  difference() {
    union() {
      difference() {
        sphere(r=sphere_r, $fn=50);
        translate([0,0,-cube_w/2])
          cube(cube_w, center=true);
        sphere(r=sphere_r - sphere_wall_th, $fn=50);
      }
      cylinder(d=11, h=sphere_r-sphere_wall_th+0.1);
    }
    translate([0,0,-screw_length/2+1]) {
      screw();
      // Give screw a hat for easier printing
      translate([0,0,screw_length-0.01])
        cylinder(r1=screw_r-0, r2=0, h=screw_r);
    }
  }
  // Vertical walls
  inner_cube_l = 2*(sphere_r-sphere_wall_th+0.1);
  intersection() {
    for(k=[0,90])
      rotate([0,0,k])
        difference() {
          translate([-inner_cube_l/2, -sphere_wall_th/2, 0])
            cube([inner_cube_l, sphere_wall_th, inner_cube_l/2]);
          translate([0,0,-1])
            cylinder(r=screw_r+0.2, h=screw_length+1);
        }
    sphere(r=sphere_r - sphere_wall_th/2);
  }
}

bottom_cap();
module bottom_cap() {
  difference() {
    top_cap();
    translate([0,0,sphere_r-8])
      cylinder(d=3, h=12, $fn=10);
  }
}
