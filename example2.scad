// Customizable parameters
wall_thickness = 4;        // 
D = 300;                // outer diameter of 
dPiston=50; // piston diameter
height = 150;               // lngth of work cilinder for piston
hWaterCamber=20;

disk_thickness = 10;


include <gears.scad>

// Model code below
module tube(dMax, thikness, lenghth) {
  difference() {
    cylinder(h=lenghth, r1=dMax/2, r2=dMax/2);
   
    translate([0, 0, -1])
        
    cylinder(lenghth+2, (dMax-thikness/2)/2, ((dMax-thikness/2))/2);
  }
}


module disk(dMax, thikness) {
    cylinder(thikness, dMax/2, dMax/2);
}


tube(D, wall_thickness, height);

translate([0, 0, -1])
  disk(D, disk_thickness);

translate([0, 0, height-2*wall_thickness-2])
  difference() {
    disk(D+60, disk_thickness);
   
    translate([0, 0, -1])
        
    cylinder(D+2, 25, 25);
  }


color("orange")
translate([0, 0, height])
  difference() {
    disk(D+60, disk_thickness);
   
    translate([0, 0, -1])
        
    cylinder(disk_thickness+2, 25, 25);
  }
  
color("orange")  
translate([0, 0, height+disk_thickness])
  tube(D, wall_thickness, hWaterCamber);  

  color("orange")
translate([0, 0, height+disk_thickness+hWaterCamber])
  difference() {
    disk(D, disk_thickness);
   
    translate([0, 0, -1])
        
    cylinder(disk_thickness+2, 25, 25);
  }
  
  
  
  
  color("orange")
  translate([0, 0, height])
    tube(dPiston, 2, 150);


translate([40, -40, 300])
rotate([90,0,90])
herringbone_gear (modul=4, tooth_number=30, width=5, bore=4, pressure_angle=20, helix_angle=0, optimized=true);



/*
// text
color("black")
translate([400, -400, 300])
rotate([90,0,90])
linear_extrude(height = 15) {
text("Stirling engine", size=100, font="Liberation Sans", halign="left", valign="baseline", spacing=1);
}
//text("ggg", 20,"Liberation Sans")
*/