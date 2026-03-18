// Кривошипно‑повзунний механізм (спрощений)
// Параметри: довжина кривошипа, довжина шатуна, положення кута

module crank_slider(crank_radius=40, rod_length=120, rod2_length=120, angle=0) {
    w=10;




    // Привод
    color("red")
    cylinder(h=w, r=w/2, $fn=50);


    // Кривошип (плечо)
    color("blue")
    rotate([0,0,angle])
        translate([0,-w/4,w/4])
            cube([crank_radius,w/2,w/2]);

    
    // Кривошип (диск)
    color("green")
    rotate([0,0,angle])
        translate([crank_radius,0,0])
            cylinder(h=10, r=w/2, $fn=50);

    
    
    // Шатун (з'єднання кривошипа з повзуном)
    // Кінцева точка кривошипа
    x_crank = crank_radius*cos(angle);
    y_crank = crank_radius*sin(angle);

    // Положення повзуна (по осі X)
    //x_slider = x_crank + sqrt(rod_length*rod_length - y_crank*y_crank);

    // Положення повзуна (по осі X, Y=0)
    x_slider = sqrt(rod_length*rod_length - y_crank*y_crank) + x_crank;


     // Кут шатуна відносно осі X
    rod_angle = atan2(y_crank, x_slider - x_crank);
    
    
    // Шатун як стрижень
    
    color("aqua")
    translate([x_crank,y_crank,0])
       translate([0,-w/4,w/4]) // center rod
          rotate([0,0,-rod_angle])
             cube([rod_length,w/2,w/2]);
             
             

    // Повзун (блок)
    color("purple")
    translate([x_slider,0,0])
        cylinder(h=10, r=w/2, $fn=50);


    translate([x_slider,0,0])
       translate([0,-w/4,w/4]) // center rod
             cube([rod2_length,w/2,w/2]);



    color("yellow")
        translate([x_slider+rod2_length,0,0])
          rotate([0,90,0])
            cylinder(h=100, r=50, $fn=50);             

}


// Виклик модуля
// angle можна анімувати через параметр $t
crank_slider(crank_radius=50, rod_length=200, rod2_length=100,  angle=$t*360);
