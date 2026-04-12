Dmax=140; // diameter of main volume
wallThikness=3; // Товщина стінки обєму з водою 
hWaterChamber=30; // Висота об'єму з водою 
lFaska=5; // Величина виступ-зацепа зверху об'єму з водою 

// Model code below
module tube(dMax, thikness, lenghth) {
  difference() {
    cylinder(h=lenghth, r1=dMax/2, r2=dMax/2);
   
    translate([0, 0, -1])
        
    cylinder(lenghth+2, dMax/2-thikness, dMax/2-thikness);
  }
}


module disk(dMax, thikness) {
    cylinder(thikness, dMax/2, dMax/2);
}


////////////////////////

module main() {
    
// Дно
disk(Dmax, wallThikness);

// Бокова стінка яка всередині циліндра
translate([0, 0, wallThikness])
  tube(Dmax, wallThikness, hWaterChamber/2);

color("orange")  
translate([0, 0, wallThikness+hWaterChamber/2])
  tube(Dmax+2*lFaska, lFaska+wallThikness, wallThikness);


// Бокова стінка яка ззовні циліндра
translate([0, 0, 2*wallThikness+hWaterChamber/2])
  difference() {

    tube(Dmax+2*lFaska, wallThikness, hWaterChamber/2);
   
     // Отвір для вводу води 
     translate([0, Dmax/2+lFaska-wallThikness-2, 1])
       rotate([-90,0,0])
         cylinder(wallThikness+15-1, 1, 1);

     // Отвір для виводу води 
     translate([0, -(Dmax/2+lFaska-wallThikness-2), 1])
       rotate([90,0,0])
         cylinder(wallThikness+15-1+500, 1, 1);

  }
/*  
  color("red") 
translate([0, 0, 2*wallThikness+hWaterChamber/2])  

translate([0, Dmax/2+lFaska-wallThikness-2, 1])
  rotate([-90,0,0])
    cylinder(wallThikness+15-1, 1, 1);
*/  

// Верхня кришка
translate([0, 0, 2*wallThikness+hWaterChamber])
  disk(Dmax+2*lFaska, wallThikness);


// Сосок отвору для вводу води     
translate([0, Dmax/2+lFaska-wallThikness-1, 2*wallThikness+hWaterChamber/2+1])
  rotate([-90,0,0])
    tube(4, 1, 15);

// Сосок отвору для виводу води     
translate([0, -(Dmax/2+lFaska-wallThikness-1), 2*wallThikness+hWaterChamber/2+1])
  rotate([90,0,0])
    tube(4, 1, 15);

    
/*
  difference() {
    disk(Dmax+lFaska, wallThikness);
   
    //translate([0, 0, -1])
        
    disk(Dmax, wallThikness);
  }
  */
  
 }

main();
 
 
 
 

rotate([0,-90,0])
  translate([-100,0,0])
    projection(cut=true)
      translate([0,0,0])
        rotate([0,90,0]) main(); 
 
