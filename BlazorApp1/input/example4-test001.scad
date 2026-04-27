Dmax=140; // diameter of main volume
wallThikness=3; // Товщина стінки обєму з водою 
hWaterChamber=30; // Висота об'єму з водою 
lFaska=5; // Величина виступ-зацепа зверху об'єму з водою 
DWorkPiston=10; // Діаметр робочого(их) поршня(ів)
LWorkPiston=16; // Довжина робочого(их) поршня(ів)
LWorkCilinder=hWaterChamber+wallThikness+30; // Довжина робочого(их) циліндра(ів)
LxCilinder=62; // Відстань центру робочого(их) циліндра(ів) від центра деталі


dCentralHole=1; // Отвір посередині для штоку поршня-теплоакумулятора



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

module torus(major_r, minor_r) {
    rotate_extrude($fn=100)
        translate([major_r, 0, 0])
        circle(r = minor_r, $fn=50);
}



////////////////////////

module main() {
    
// Дно  
difference() {
  disk(Dmax, wallThikness);
  
  // Центральний отвір штока термопоршня  
  translate([0, 0, -0.1])
  cylinder(wallThikness+0.2, dCentralHole/2, dCentralHole/2);
    
  // Отвір робочого поршня
  rotate([0,0,45])
    translate([LxCilinder, 0, -0.1])
      cylinder(wallThikness+0.2, DWorkPiston/2-2, DWorkPiston/2 -2);
}

// Бокова стінка яка всередині циліндра
translate([0, 0, wallThikness])
  tube(Dmax, wallThikness, hWaterChamber/2);

//color("orange")  
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
     translate([0, -(Dmax/2+lFaska-wallThikness-2), hWaterChamber/2-1])
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
  difference() {
    disk(Dmax+2*lFaska, wallThikness);
    
    // Центральний отвір штока термопоршня  
    translate([0, 0, -0.1])
      cylinder(wallThikness+0.2, dCentralHole/2, dCentralHole/2);
    
    // Отвір робочого поршня
    rotate([0,0,45])
      translate([LxCilinder, 0, -0.1])
        cylinder(wallThikness+0.2, DWorkPiston/2, DWorkPiston/2);
  }

// Штуцер для вводу води     
translate([0, Dmax/2+lFaska-wallThikness-1, 2*wallThikness+hWaterChamber/2+1])
  rotate([-90,0,0])
    tube(4, 1, 15);

// Штуцер для виводу води     
translate([0, -(Dmax/2+lFaska-wallThikness), 2*wallThikness+hWaterChamber-1])
  rotate([90,0,0])
    tube(4, 1, 15);


// Отвір посередині для штоку поршня-теплоакумулятора
translate([0, 0, wallThikness])
  tube(dCentralHole+2*wallThikness, wallThikness, hWaterChamber+wallThikness);


// опора важеля
rotate([0,0,45])
  translate([LxCilinder/2, 0, hWaterChamber+2*wallThikness])
    difference() {
    union()
    {
     
     translate([0, -5, 0])   
      cube([10, 10, LWorkCilinder-hWaterChamber-2*wallThikness]);

      translate([5, -5, LWorkCilinder-hWaterChamber-2*wallThikness])
        rotate([0,90,90])
          cylinder(10,5,5);
     };
     
      translate([5, -5, LWorkCilinder-hWaterChamber-2*wallThikness])
        rotate([0,90,90])
          cylinder(10,1,1);

      translate([0, 3-5, LWorkCilinder-hWaterChamber-2* wallThikness-10])
     cube([10, 4, 20]);

 };

// Циліндр робочого поршня
rotate([0,0,45])
  translate([LxCilinder, 0, 0])
    tube(DWorkPiston+2*wallThikness, wallThikness, LWorkCilinder);

// Верхній бортик циліндра робочого поршня
rotate([0,0,45])
  translate([LxCilinder, 0, LWorkCilinder-1])
    tube(DWorkPiston+2*wallThikness+2, wallThikness, 1);  
    
    
// Робочий поршень
rotate([0,0,45])
  translate([LxCilinder+20,0,0])
    difference() {
      cylinder(LWorkPiston, DWorkPiston/2-0.1,DWorkPiston/2-0.1);  

      translate([0,0,LWorkPiston-1])
        torus(DWorkPiston/2-0.1, 1);  
  
      translate([0,0,2])
        torus(DWorkPiston/2-0.1, 1);  
    }
  
/* 
translate([0, LWorkCilinder, 2*wallThikness+hWaterChamber+DWorkPiston/2])
  rotate([-90,90,0])
     tube(DWorkPiston, wallThikness, LWorkCilinder);
    
translate([0, LWorkCilinder+LWorkCilinder-wallThikness, 2*wallThikness+hWaterChamber+DWorkPiston/2])
  rotate([-90,90,0])
     cylinder(wallThikness, DWorkPiston+wallThikness, DWorkPiston+wallThikness);     

*/
  
 }

main();
 
 
 
 

rotate([0,-90,0])
  translate([-100,0,0])
    projection(cut=true)
      translate([0,0,0])
        rotate([0,90,0]) 
          main(); 
 

rotate([0,-90,0])
  translate([-200,0,0])
    projection(cut=true)
      translate([0,0,0])
        rotate([45,0,0]) 
         rotate([0,90,0]) 
           main(); 