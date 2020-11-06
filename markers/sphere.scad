use <revolve2.scad>

module standing_ls_tri(l, h){
  difference(){
    cube([l,l,h]);
    translate([l,0,0])
      rotate([0,0,45])
      translate([0,0,-1])
      cube([l*sqrt(2),l*sqrt(2),h+2]);
  }
}

module rounded_cube2(v, r){
  $fs = 1;
  if(v[2]){
    union(){
      translate([r,0,0])           cube([v[0]-2*r, v[1]    , v[2]]);
      translate([0,r,0])           cube([v[0]    , v[1]-2*r, v[2]]);
      translate([r,r,0])           cylinder(h=v[2], r=r);
      translate([v[0]-r,r,0])      cylinder(h=v[2], r=r);
      translate([v[0]-r,v[1]-r,0]) cylinder(h=v[2], r=r);
      translate([r,v[1]-r,0])      cylinder(h=v[2], r=r);
    }
  } else {
    union(){
      translate([r,0])           square([v[0]-2*r, v[1]    ]);
      translate([0,r])           square([v[0]    , v[1]-2*r]);
      translate([r,r])           circle(r=r);
      translate([v[0]-r,r])      circle(r=r);
      translate([v[0]-r,v[1]-r]) circle(r=r);
      translate([r,v[1]-r])      circle(r=r);
    }
  }
}


screw_length=8;
screw_length_inner=screw_length+2;
screw_r=4.5;

//!intersection(){
//scale([(screw_r-0.05)/screw_r,(screw_r-0.05)/screw_r,1])
//translate([0,0,-screw_length/2])
//screw();
//top_cap();
//}

// It can be a good idea to scale down screw xy before exporting.
//scale([(screw_r-0.05)/screw_r,(screw_r-0.05)/screw_r,1])
//screw();
module screw(h=screw_length) {

  //// A sinusoidal profile function...
  //period = 3;
  //function prof_sin(z) = [z, 10+sin(z*360/period)];
  //// ...which becomes a profile vector with the help of linspace
  //sin_prof = [for (z=linspace(start=0, stop=period, n=15)) prof_sin(z)];
  //revolve( sin_prof, length=30, nthreads=2, $fn=30);

  revolve(profile = [[0, screw_r-0.5], [0.4, screw_r], [1.0, screw_r-0.5]], length=h, nthreads=2, $fn=40);
}

sphere_r = 16;
sphere_wall_th = 1.0;
sphere_wall_th_top = 0.5;
sphere_wall_th_bottom = 1.2;
cube_w = 2*sphere_r+2;

//// Inspect section cut
//!difference() {
//  top_cap();
//  rotate([0,0,45])
//  translate([-30,0,-1])
//  cube(60);
//}
//top_cap();
module top_cap() {
  difference() {
    top_cap_no_screw();
    translate([0,0,-(screw_length_inner)/2])
      screw(screw_length_inner);
  }
}

module top_cap_no_screw() {
  difference() {
    union() {
      difference() {
        sphere(r=sphere_r, $fn=100);
        translate([0,0,-cube_w/2])
          cube(cube_w, center=true);
        bottom_scale = (sphere_r-sphere_wall_th_bottom)/sphere_r;
        top_scale = (sphere_r-sphere_wall_th_top)/sphere_r;
        scale([bottom_scale, bottom_scale, top_scale])
          sphere(r=sphere_r, $fn=100);
      }
      intersection() {
        cylinder(d=screw_r*2+sphere_wall_th*2, h=sphere_r);
        sphere(r=sphere_r-sphere_wall_th/3);
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
    translate([0,0,-screw_length_inner/2]) {
      // Give screw a hat for easier printing
      translate([0,0,screw_length_inner-0.01])
        cylinder(r1=screw_r-0, r2=0, h=screw_r);
    }
  }
}

//bottom_cap();
module bottom_cap() {
  difference() {
    top_cap_no_screw();
    translate([0,0,sphere_r-8])
      cylinder(d=3, h=12, $fn=10);
    rotate([180,0,0])
      translate([0,0,-screw_length_inner/2])
      screw(screw_length_inner);
  }
}

//difference() {
//  marker_slider();
//  translate([-50,-50,0])
//    cube(100);
//}
marker_slider();
module marker_slider() {
  zip_th = 2;
  zip_w = 4.5;
  wall_th = 2.7;
  h = 2*zip_w + 3 + 2;
  extra_length = 6;
  w = 12.5 + wall_th;

  translate([0,0,-h/2])
    difference() {
      union() {
        translate([-w/2,-w/2,0])
          rounded_cube2([w, wall_th, h],1,$fn=4*4);
        translate([-w/2,-w/2,0])
          rounded_cube2([wall_th, w, h],1,$fn=4*4);
        // A small volcano shaped tip
        translate([-w/2+0.01,0,h/2])
          rotate([0,-90,0])
          cylinder(d1=6.5, d2=3.5, h=1.5, $fn=20);
        // Two walls to keep zip tie in place
        for (zang=[0,90]) {
          rotate([0,0,zang]) {
            translate([-w/2+0.01,0,h])
              rotate([90,180,0])
              translate([0,0,-w/2+wall_th])
              standing_ls_tri(0.8, w-wall_th*2);
            translate([-w/2+0.01,0,0])
              rotate([90,0,180])
              translate([0,0,-w/2+wall_th])
              standing_ls_tri(0.8, w-wall_th*2);
          }
        }
        // A little helper while mounting.
        // Perhaps over-complicating things,
        // would set a max thickness on zipties,
        // so trying to do without it first
        //translate([0, -w/2-1.8+0.001, 0])
        //  cube([2, 1.8, 0.8]);
        //translate([0, -w/2-1.8+0.001, 0])
        //  cube([2, 1.0, h]);
        //translate([0, -w/2-1.8+0.001, h-0.8])
        //  cube([2, 1.8, 0.8]);
      }
      // inner corner cutout
      translate([-w/2+wall_th+0.50, -w/2+wall_th+0.50, -1])
        cylinder(r=0.75, h=h+2, $fn=15);

      translate([0,0,h/2])
        rotate([0,-90,0]){
          // screw hole
          cylinder(d=3.4, h=100, $fn=20);
          // hex screw head cutout
          cylinder(d=6.4, h=w/2-wall_th+2.1, $fn=6);
        }

    }
}

//show();
module show(){
  translate([0,0,sphere_r+4])
    difference() {
      rotate([0,0,45])
        union() {
          translate([0,0,-screw_length/2])
            scale([(screw_r-0.05)/screw_r,(screw_r-0.05)/screw_r,1])
            screw();
          top_cap();
          rotate([0,180,0])
            bottom_cap();
        }
      translate([0, -4*screw_r, -4*screw_r])
        cube(8*screw_r);
    }
  color("grey") {
    cylinder(d=3, h=8);
    cylinder(d=6.23, h=2, $fn=6);
  }
  translate([0,0,-5])
    rotate([0,90,0])
    marker_slider();
}
