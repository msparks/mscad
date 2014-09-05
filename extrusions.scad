// This is a better version of rotate_extrude() that adds a sweep angle.
//
// Args:
//   outer_radius: Largest radius of children when rotated about the origin.
//   min_z: Minimum Z-axis component of the children.
//   max_z: Maximum Z-axis component of the children.
//   sweep: Sweep angle; [0, 360].
//   convexity: Same as for rotate_extrude.
//
// The outer_radius, min_z, and max_z arguments are used to calculate the
// bounding box of the extrusion. They don't have to be exact, and in fact, it
// may be desirable to specify a bounding box smaller than the full extrusion.
//
// The bounding box parameters are required because OpenSCAD does not offer a
// way to probe the children of a module. See
// https://github.com/openscad/openscad/issues/301.
module rotate_extrude_sweep(outer_radius, min_z, max_z, sweep, convexity=10) {
  module _bounding_box() {
    // TODO(msparks): Use concat() when it is not experimental.
    angle_point = [-outer_radius * sin(sweep - 90),
                   outer_radius * cos(90 - sweep)];
    height = max_z - min_z;
    linear_extrude(height=height, center=false, convexity=convexity, twist=0)
    if (0 < sweep && sweep <= 90) {
      polygon(points=[[0, 0], [outer_radius, 0], [outer_radius, outer_radius],
                      angle_point]);
    } else if (90 < sweep && sweep <= 180) {
      polygon(points=[[0, 0], [outer_radius, 0], [outer_radius, outer_radius],
                      [-outer_radius, outer_radius], angle_point]);
    } else if (180 < sweep && sweep <= 270) {
      polygon(points=[[0, 0], [outer_radius, 0], [outer_radius, outer_radius],
                      [-outer_radius, outer_radius],
                      [-outer_radius, -outer_radius],
                      angle_point]);
    } else if (270 < sweep && sweep <= 360) {
      polygon(points=[[0, 0], [outer_radius, 0], [outer_radius, outer_radius],
                      [-outer_radius, outer_radius],
                      [-outer_radius, -outer_radius],
                      [outer_radius, -outer_radius],
                      angle_point]);
    }
  }

  // Uncomment this if you want to see how the bounding box is built.
  //%translate([0, 0, min_z]) _bounding_box();

  if (sweep <= 0) {
    echo("WARNING: rotate_extrude_sweep: sweep angle must be greater than 0.");
  } else if ($children <= 0) {
    echo("WARNING: rotate_extrude_sweep: no children.");
  } else {
    intersection() {
      rotate_extrude(convexity=convexity) children();
      translate([0, 0, min_z]) _bounding_box();
    }
  }
}

module test_extrusions() {
  $fn = 40;

  // Toroid with a square.
  rotate_extrude_sweep(outer_radius=4, min_z=2, max_z=3, sweep=170)
  translate([3, 2, 0])
  square(r=1);

  // Top half of orus. Notice the bounding box is smaller than the full
  // extrusion!
  rotate_extrude_sweep(outer_radius=1.5, min_z=0, max_z=0.5, sweep=240)
  translate([1, 0, 0])
  circle(r=0.5);

  // Toroid using a weird polygon.
  // The bounding box is much larger than the extrusion, but that's fine.
  rotate_extrude_sweep(outer_radius=10, min_z=-7, max_z=2, sweep=310)
  translate([1, -4, 0])
  polygon(points=[[0, 0], [3, 0], [5, 1], [6, 3]]);
}
