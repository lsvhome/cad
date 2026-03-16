// Customizable parameters
wall_thickness = 2;        // [1:0.5:5] Wall thickness in mm
width = 250;                // [20:100] Width in mm
height = 60;               // [10:80] Height in mm
rounded = false;            // Add rounded corners

// Model code below
module engine() {
    if (rounded) {
        minkowski() {
            cube([width - 4, width - 4, height - 2]);
            sphere(r = 2);
        }
    } else {
        cylinder(height, width, width);
    }
}

difference() {
    cylinder(height, width, width);
    
    translate([0, 0, wall_thickness])
        
        scale([1 - wall_thickness/width, 1 - wall_thickness/width, 1])
        
            cylinder(height, width, width);
}