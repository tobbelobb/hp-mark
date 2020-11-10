

// For some reason, we've lost perfect squareness by ~.1%
// It might be the pdf that is off, or it might be the program
// pdf2svg that has bad truncation errors internally,
// or it might be Blender that has the truncation errors.
// Blender was used to convert the intermediate svg image into
// chessmesh.stl, charucomesh.stl, and charucointernal.stl
measured_x_length = 1440.0297403;
measured_y_length = 989.8103476;

// With these lengths, each chess square side is 90 mm wide
// And each marker is 70 mm wide
wanted_x_length = 1440;
wanted_y_length = 990;

translate([-wanted_x_length/2, wanted_y_length/2, 0]) {
  scale([wanted_x_length/measured_x_length, wanted_y_length/measured_y_length,1]) {
    color("black")
      scale([1000, 1000, 0.005])
      import("./chessmesh.stl");
    color("black")
      scale([1000,1000,0.005])
      import("./charucomesh.stl");
    color("white")
      translate([0,0,-0.0005])
      scale([1000,1000,0.25])
      import("./charucointernal.stl");
  }
}
//$t=0.7;

// Ok, but not fantastic values
//$vpr = [45,0,360*$t];
//$vpt = [130*sin(360*$t),-130*cos(360*$t),0];
//$vpd = 2500+1000*abs(sin(360*2*$t));

// For animating a bunch of frames, you can use this
vprs = [[ 49.90, 0.00, 359.60 ],
        [ 52.70, 0.00, 29.00 ],
        [ 53.40, 0.00, 60.50 ],
        [ 46.40, 0.00, 90.60 ],
        [ 47.80, 0.00, 120.70 ],
        [ 42.90, 0.00, 154.30 ],
        [ 34.50, 0.00, 180.20 ],
        [ 50.60, 0.00, 196.30 ],
        [ 52.00, 0.00, 221.50 ],
        [ 48.50, 0.00, 261.40 ],
        [ 49.20, 0.00, 279.60 ],
        [ 51.30, 0.00, 323.70 ]];
vpts = [[ -2.39, -66.23, 37.04 ],
        [ 37.14, -122.39, -54.19 ],
        [ 136.35, 12.34, -81.12 ],
        [ 107.45, 12.39, -49.25 ],
        [ 91.81, 65.31, -63.52 ],
        [ 80.53, 52.77, -48.47 ],
        [ -7.27, 54.79, -48.38 ],
        [ 50.34, 79.79, -78.75 ],
        [ -94.89, -6.90, -120.59 ],
        [ -75.61, -43.08, -92.93 ],
        [ -73.70, -38.31, -89.82 ],
        [ -90.66, -35.63, -99.43 ]];
vpds = [2264.24, 2296, 2557, 2547.78, 2886, 2800, 2215, 2215, 2673, 2673, 2673, 2592];

// Writing a bash script with OpenScad echo function...
//for (i=[0:len(vprs)-1]) {
//  echo(vpts[i], vprs[i], vpds[i]);
//}

//index = round($t*len(vprs));
//$vpr = vprs[index];
//$vpt = vpts[index];
//$vpd = vpds[index];
