

// For some reason, we've lost perfect squareness by ~.1%
// It might be the pdf that is off, or it might be the program
// pdf2svg that has bad truncation errors internally,
// or it might be Blender that has the truncation errors.
// Blender was used to convert the intermediate svg image into
// chessmesh.stl, charucomesh.stl, and charucointernal.stl
measured_x_length = 1440.0297403;
measured_y_length = 989.8103476;

// With these lengths, each chess square side is 90 mm wide
wanted_x_length = 1440;
wanted_y_length = 990;

scale([wanted_x_length/measured_x_length, wanted_y_length/measured_y_length,1]) {
  color("black")
    scale([1000, 1000, 0.01])
    import("./chessmesh.stl");
  color("black")
    scale([1000,1000,0.01])
    import("./charucomesh.stl");
  color("white")
    translate([0,0,-0.001])
    scale([1000,1000,0.5])
    import("./charucointernal.stl");
}

