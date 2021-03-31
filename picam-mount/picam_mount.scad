module inner_round_corner(r, h, ang=90, back = 0.1){
  cx = r*(1-cos(ang/2+45));
  translate([-r*(1-sin(ang/2+45)), -r*(1-sin(ang/2+45)),0])
  difference(){
    translate([-back, -back, 0])
    cube([cx+back, cx+back, h]);
    translate([r,r,-1])
      cylinder(r=r, h=h+2);
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

module top_rounded_cube2(v, r){
  translate([0,v[1],0])
    rotate([90,0,0])
      rounded_cube2([v[0], v[2], v[1]], r);
}


$fn=100;
module snurreskive_plate(){
  cylinder(d1 = 22, d2 = 17, h = 6.1);
}

module snurreskive_plate_plupp() {
  difference(){
    union() {
      translate([-3, -27/2/2, 0])
        top_rounded_cube2([6, 27/2, 14.3], 3);
      for(k=[0,1])
        mirror([k,0,0])
          translate([6/2, 27/2/2, 6.1])
          rotate([90,0,0])
          inner_round_corner(1, 27/2);
    }
    translate([0,0,14.3-3])
      rotate([90,0,0])
        cylinder(d=3.1, h=41, center=true);
  }
}

//!snurreskive();
module snurreskive() {
  snurreskive_plate();
  snurreskive_plate_plupp();
}

width = 23.7;
height = 25;
th = 2;
screw_offs = 2;
screw_d = 2;
die_w = 8.34;


//!picam_die();
module picam_die(){
    translate([0,0,-0.1]) {
      cylinder(d = 7.18, h=6+0.1);
      translate([-die_w/2, -die_w/2, 0])
        cube([die_w, die_w, 3.3+0.1]);
    }
}


lower_lens_hood_base = 2.0;

//!rotate([180,0,0]) lens_hood_legs();
//!lens_hood_legs();
module lens_hood_legs() {
  difference(){
    translate([-10/2,-height/2,  0])
      cube([10,height,  6.9-lower_lens_hood_base]);
    cylinder(d = 8.0, h=10);
    translate([-die_w, -die_w, -0.1])
      cube([2*die_w, 2*die_w, 4.0]);

    translate([0,height/2-screw_offs,-1])
      cylinder(d=2.1, h=10);
    translate([0,-(height/2-screw_offs),-1])
      cylinder(d=2.1, h=10);
  }
}

//translate([0,0,-6.9])
//lens_hood_legs();
//%difference(){
//  cylinder(d = 33, h=2);
//  translate([0,0,-2])
//    cylinder(d = 25, h=5.1);
//
//}


//translate([0,0,-lower_lens_hood_base])
//lens_hood();
module lens_hood() {
  // Magic numbers almost copied picam v2 spec.
  hood_height = 16;
  v = 66/2;
  a = 3.68/2;
  b = tan(v)*hood_height - a;
  s = b/a;
  difference() {
    union(){
      translate([-5, -height/2, 0])
        cube([10,height,  1]);
      rotate([0,0,led_ring_1_rotation])
        rotate([0,0,90])
          translate([-35/2, -10/2, 0])
            rounded_cube2([35,10,1], 10/2);
      rotate([0,0,led_ring_2_rotation])
        rotate([0,0,90])
          translate([-42/2, -10/2, 0])
            rounded_cube2([42,10,1], 10/2);
      rotate([0,2,0])
        cylinder(d=7.18+2.5, h = hood_height-11);
    }
    translate([0,0,-50])
      cube(100, center=true);
    rotate([0,2,0]){
      translate([0,height/2-screw_offs,-1])
        cylinder(d=2.1, h=10);
      translate([0,-(height/2-screw_offs),-1])
        cylinder(d=2.1, h=10);
      rotate([0,0,led_ring_1_rotation])
        translate([0,-29/2,-1])
          cylinder(d=2.1, h=10);
      rotate([0,0,led_ring_1_rotation])
        translate([0,29/2,-1])
          cylinder(d=2.1, h=10);
      rotate([0,0,led_ring_2_rotation])
        translate([0,-34.8/2,-1])
          cylinder(d=2.1, h=10);
      rotate([0,0,led_ring_2_rotation])
        translate([0,34.8/2,-1])
          cylinder(d=2.1, h=10);
      translate([0,0,-2])
        cylinder(d=7.18, h = hood_height+2);
      translate([0,0,-1.75+lower_lens_hood_base])
        linear_extrude(height=hood_height, scale=s)
          square([2.76, 3.68], center=true);
    }
    for (k = [0,1]) {
      mirror([0,k,0]) {
        translate([-2.5,7,-1])
          cube([5,0.5,3]);
        translate([2.5,7.25,-1]){
          rotate([0,0,135])
            translate([-0.25,-0.25,0])
            cube([2,0.5,3]);
          rotate([0,0,-135])
            translate([-0.25,-0.25,0])
            cube([2,0.5,3]);
        }
      }
    }
  }
}

//translate([9, -24/2, -7])
//picam();
module picam() {
  difference() {
    cube([width, height, th]);
    translate([screw_offs, screw_offs, -1])
      cylinder(d=screw_d, h=4);
    translate([12.5+screw_offs, screw_offs, -1])
      cylinder(d=screw_d, h=4);
    translate([12.5+screw_offs, 25-screw_offs, -1])
      cylinder(d=screw_d, h=4);
    translate([screw_offs, 25-screw_offs, -1])
      cylinder(d=screw_d, h=4);
  }
  translate([12.5+screw_offs, height/2, th-0.1]) {
  color("grey")
    picam_die();
    lens_hood_legs();
    translate([0,0,7-lower_lens_hood_base])
      rotate([0,0,180])
      lens_hood();
  }
}

//arducam();
module arducam() {
  screw_offs = 3.5;
  side_l = 36.1;
  difference(){
    color("green")
    cube([side_l, side_l, 1.5]);
    for(k = [0, 1]) {
      for(l = [0, 1]) {
        translate([screw_offs + k*(side_l - 2*screw_offs),
                   screw_offs + l*(side_l - 2*screw_offs), -1])
          cylinder(d=3.1, h=4);
      }
    }
  }
  translate([side_l/2, side_l/2, 1])
    color([0.2,0.2,0.2])
    cylinder(d=14, h=24);
  translate([2*screw_offs, side_l-5.5, 1])
    color("white")
    cube([side_l-4*screw_offs, 5.5, 4.25-1]);
}

module snurreskive2_inner() {
  cylinder(d1 = 31.5, d2 = 28.5, h=5.1);
}


//!translate([(31)/2+3.5,0,-2]) {
//  snurreskive2_picam();
//  translate([-2-12.5/2, -25/2, 9.6])
//    %picam();
//}
module snurreskive2_picam() {
  difference() {
    union() {
      snurreskive2_inner();
      for(i=[1,-1])
        for(j=[1,-1])
          translate([i*12.5/2, j*21/2, 0])
            cylinder(d=4, h=9.5);
    }
    for(i=[1,-1])
      for(j=[1,-1])
        translate([i*12.5/2, j*21/2, -0.1]) {
          cylinder(d=2.1, h=9.7);
          // M2 nutlocks. Most people won't have M2 screws, so don't bother
          //cylinder(d=4/cos(30), h=2, $fn=6);
        }
  }
}

led_ring_1_rotation = -18;
module led_ring_1() {
  difference(){
    cylinder(d=32, h=3);
    translate([0,0,-1])
      cylinder(d=18, h=5);
    rotate([0,0,led_ring_1_rotation])
      for (k = [0,1])
        mirror([k,0,0])
          translate([(32/2)-2, 0, -1])
            cylinder(d=2.5, h=5);
  }
}

led_ring_2_rotation = 18;
module led_ring_2() {
  difference(){
    cylinder(d=39, h=3);
    translate([0,0,-1])
      cylinder(d=27, h=5);
    rotate([0,0,led_ring_2_rotation])
      for (k = [0,1])
        mirror([k,0,0])
          translate([(39/2)-2, 0, -1])
            cylinder(d=2.5, h=5);
  }
}

fan();
module fan(){
  translate([-20,-11-36/2,7])
    difference(){
      cube([40, 11, 40]);
      translate([-32/2+20, 0, (40-32)/2])
        rotate([90,0,0])
          cylinder(d=4, h=25, center=true);
      translate([32/2+20, 0, (40-32)/2])
        rotate([90,0,0])
          cylinder(d=4, h=25, center=true);
    }
}

fan_block();
module fan_block(){
  translate([-20,-11-36/2,7])
      translate([-32/2+20, 17, (40-32)/2])
        rotate([90,0,0])
          difference(){
            cylinder(d=4, h=20);
            translate([-11,-23,-1])
              cube(22);
            translate([-11,1,6-22])
              cube(22);
          }
}

//led_ring_holder_arducam2();
module led_ring_holder_arducam2() {
  difference(){
    union(){
      translate([0, 0, 21])
        cylinder(d1=60, d2=20, h=18);
      translate([0, 0, 10])
        cylinder(d=19, h=35);
    }
    for(k=[0,1]) mirror([k,0,0])
    translate([8.5,-1,37])
      cube([4,2,10]);
    translate([0, 0, -1])
      cylinder(d=14, h=100);
    translate([0,0,37])
      led_ring_1();
    translate([0,0,40.5])
      led_ring_2();
  }
}

//!rotate([180,0,0])
//led_ring_holder_arducam();
module led_ring_holder_arducam() {
  difference(){
    union(){
      translate([-40/2, -20/2, 27+7.5+2.5-2])
        cube([40, 20, 2]);
      for (k = [0,1])
        mirror([k,0,0]) {
          translate([-40/2+3,0,27+7.5+2.5-2])
            rotate([-90,0,0])
              translate([0,0,-20/2])
                inner_round_corner(3, 20);
          translate([-40/2, -20/2, 9])
            difference(){
              cube([3, 20, 26]);
              translate([2,-1,1])
                cube([3, 22, 1.7]);
            }
        }
    }
    rotate([0,0,led_ring_1_rotation])
      for (k = [0,1])
        mirror([k,0,0])
          translate([(32/2)-2, 0, 36])
            cylinder(d=2.5, h=11, center=true);
    rotate([0,0,led_ring_2_rotation])
      for (k = [0,1])
        mirror([k,0,0])
          translate([(39/2)-2-1, 0, 36])
            rotate([0,45,0])
              cylinder(d=2.5, h=11, center=true);
    hull(){
      cylinder(d=15, h=38);
      translate([0,20,0])
        cylinder(d=15, h=38);
    }
  }

}


//rotate([0,180,0])
snurreskive2_arducam();
translate([0,0,7.5+2.5]) {
  translate([-36.1/2,-18,2]) {
    arducam();
  }
  color([0.5,0.5,0.5]){
    translate([0,0,27])
      led_ring_1();
    translate([0,0,30.5])
      led_ring_2();
  }
}
module snurreskive2_arducam() {
  screw_offs = 3.5;
  cyl_height = 7.3+2.5;
  difference(){
    union(){
      snurreskive2_inner();
      cylinder(d=28.5, h=cyl_height);
      translate([-36/2, 28.5/2-3.5, cyl_height-2])
        rounded_cube2([36, 7, 2], 3.5);
      for(k = [1,0]) {
        mirror([k,0,0]){
          translate([-36/2+3.5, 28.5/2 -36 + 7, 0])
            rotate([0,0,45])
            translate([-3.5, -3.5, cyl_height-2])
            rounded_cube2([36, 7, 2], 3.5);
        }
      }
    }
    for(k = [1,0]) {
      mirror([k,0,0]){
        translate([-36/2+3.5,28.5/2,cyl_height-2.1])
          cylinder(d=3, h=5);
        translate([-36/2+3.5,28.5/2-36+7,cyl_height-2.1])
          cylinder(d=3, h=5);
        translate([18.8/2,0,7.3-2])
          cylinder(d=5, h=3);
      }
    }
  }
}

//!vippeplate();
module vippeplate(){
    difference() {
      hull() {
        rotate([90,0,0])
          cylinder(d=6, h=37, center=true);
        translate([23,0,0])
          rotate([90,0,0])
            cylinder(d=6, h=37, center=true);
      }
      rotate([90,0,0])
         cylinder(d=3.1, h=100, center=true);
      cube([6.5, 27/2, 7], center=true);
      translate([(31)/2+4,0,-2]) {
        hull() {
          snurreskive2_inner();
          translate([20,0,0]) {
            snurreskive2_inner();
          }
        }
        hull() {
          translate([0,0,-2])
            cylinder(d=28.5, h=6);
          translate([20,0,-2])
            cylinder(d=28.5, h=6);
        }
      }
      translate([31/2+4,0,0]){
        rotate([0,0,90-10])
          rotate([0,90,0])
            cylinder(d=2.4, h=50);
        rotate([0,0,90+180+10])
          rotate([0,90,0])
            cylinder(d=2.4, h=50);
      }
    }
}

//!base();
module base() {
  difference() {
    translate([0,0,-2])
      cylinder(d = 25 + 4, h=8);
    hull() {
      snurreskive_plate();
      translate([0,-10,0])
        snurreskive_plate();
    }
    rotate([0,0,90])
      translate([0,0,3.5])
        rotate([0,90,0])
          cylinder(d=2.7, h=50, center=true);
    rotate([0,0,-15])
      translate([0,0,3.5])
        rotate([0,90,0])
          cylinder(d=2.7, h=50);
    rotate([0,0,180+15])
      translate([0,0,3.5])
        rotate([0,90,0])
          cylinder(d=2.7, h=50);
    cylinder(d=3, h=10, center=true);
    translate([0,0,-2+0.01])
      cylinder(d1=3, d2=7, h=2);
  }
}

//assembly();
module assembly() {
  translate([0,0,14.3-3]) {
    vippeplate();
    translate([(31)/2+3.5,0,-2]) {
      snurreskive2();
      translate([-2-12.5/2, -25/2, 9.6])
        picam();
    }
  }
  base();
  snurreskive();
}
