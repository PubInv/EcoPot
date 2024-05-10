
// Copyright Cledden Obeng-Poku Kwanin and Robert L. Read, 2024
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to make a new parametrized experimental apparatus
// for teting our ferrofluid check valve. It will be similar to the system
// that Veronica design in SolidWorks, but will use the improved, 360 degree design


pot_height = 5;
wall_thickness =0.5;
outer_rad =5;
inner_rad = outer_rad-wall_thickness;
base_scale_factor = 2;
height_scale_factor = 0.5;
extra_height = 3;

lid_thickness = 0.4;
lid_handle_height = 1;
lid_handle_base_radius = 0.2;
lid_inner_rim_size = 0.4;

finWidth = 0.2;
finLength = outer_rad/2;
finHeight = 5;

legWidth = 0.5;
legLength = outer_rad/2;
legHeight = 5;
legBallRadius = 0.4;

PI = 3.141592;

A = 2; // aspect ratio (pure number)
V = 1000*1000; // cubic millimeters

// H = height will be a computed value
// S = height of the side 
// H = R + S
// R =  radius of the pot (mm)

function radius(A,V) = pow(V / (PI *(A + 2/3)),1/3);

function height(A,V) = A * radius(A,V);

echo(radius(A,V));
echo(height(A,V));

// ptype = "flatbottom";
// ptype = "flatbottom_with_fins";
// ptype = "roundbottom";
ptype = "roundbottom_with_fins";

// set resolution here
$fn=40;

module radialFin(angle) {
    rotate([0,0,angle])
    translate([0,outer_rad-finLength/2,-finHeight/2])
    cube([finWidth,finLength,finHeight],center=true);
}

module foilFin(angle) {
    rotate ([0,0,angle])
    translate([0,outer_rad-finLength/2,-finHeight/2])
    scale ([finWidth,finWidth*3,1])
    sphere(r=finLength);
}

module fishFoilFin(angle) {
    rotate ([0,0,angle])
    translate([0,outer_rad*0.75,-finHeight*0.83])
    scale (0.25)
    union () {
        rotate ([0,0,45])
        cylinder (h=finLength*2, r1 = finWidth*0, r2=finWidth*10,$fn = 4);
        scale ([0.5,1,2.5])
        sphere(r=finLength/2);
    }
}

module legFin(angle) {
    rotate([0,0,angle])
    translate([0,outer_rad-legLength/2,-outer_rad/2])
    union() {
        cube([legWidth,legLength,legHeight],center=true);
        translate([0,legLength/2,-legHeight/2])
        sphere(legBallRadius);
    }
}

module foilFins (num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       foilFin(delta*i);
    }
}

module fishFoilFins (num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       fishFoilFin(delta*i);
    }
}

module radialFins(num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       radialFin(delta*i);
    }
}
module legFins(num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       legFin(delta*i);
    }
}
module roundBottomOutside() {
     union () {
        color ("red")
        sphere (outer_rad);
        color("blue")
        cylinder (h=pot_height,r1=outer_rad,r2=outer_rad);
    }
}

module roundBottomPot() {
   difference() {    
        roundBottomOutside();
        union () {
            sphere (r = inner_rad);
            cylinder (h=(pot_height*2),r1 =inner_rad, r2= inner_rad);
        }
    }
}

module roundBottomPotWithFins() {
    difference () {
    //roundBottomPot();
    //union () {
        union() {
           legFins(3);
//           radialFins(12);
            roundBottomPot();
            fishFoilFins (12);
       }
        
        roundBottomOutside();
   //}
}
}


module flatBottomPot () {
    echo("flatBottomPot Called!");
    difference () {
        cylinder (h=    pot_height, r=outer_rad, center = true);
        translate ([0,0,(wall_thickness+(extra_height/2))])
        cylinder (h=pot_height+extra_height, r1=(outer_rad-wall_thickness), r2 =(outer_rad-wall_thickness), center=true);
    }
}

module flatBottomPotOutside () {
    difference () {
        cylinder (h=    pot_height, r=outer_rad, center = true);
    }
}
module flatBottomPotWithFins() {
    flatBottomPot();
    difference() {
        radialFins(16);
        flatBottomPotOutside();
    }
}

module flatLid () {
    translate ([0,0,pot_height+1])
    rotate ([180,0,0])
    union () {
        cylinder (h= lid_thickness, r=outer_rad, center = true);
        rotate ([180,0,0])
        translate ([0,0,lid_thickness/2])
        cylinder (h= lid_handle_height, r1=lid_handle_base_radius,r2=lid_handle_base_radius*5);
    translate ([0,0,lid_thickness]);
        difference () {
         cylinder (h=lid_inner_rim_size, r1=(inner_rad), r2 =(inner_rad));    
        cylinder (h=(lid_thickness+extra_height), r1=(inner_rad-lid_thickness), r2 =(inner_rad-lid_thickness));
                }
            } 
}

module conicalLid () {
    translate ([15,0,pot_height+1])
    rotate ([180,0,0])
    union () {
        difference () {
                union () {
                cylinder (h= lid_thickness, r1= lid_handle_base_radius, r2=outer_rad, center = true);
                translate ([0,0,lid_thickness])
                cylinder (h= lid_thickness, r1= outer_rad, r2=outer_rad, center = true);
                        }
                 union () {
                cylinder (h= lid_thickness, r1= lid_handle_base_radius, r2=inner_rad, center = true);
                translate ([0,0,lid_thickness])
                cylinder (h= lid_thickness, r1= inner_rad, r2=inner_rad, center = true);
                        }    
                    }
        rotate ([180,0,0])
        translate ([0,0,lid_thickness/2])
        cylinder (h= lid_handle_height, r1=lid_handle_base_radius,r2=lid_handle_base_radius*5);
    translate ([0,0,lid_thickness])
        difference () {
         cylinder (h=lid_inner_rim_size, r1=(inner_rad), r2 =(inner_rad));    
        cylinder (h=(lid_thickness+extra_height), r1=(inner_rad-lid_thickness), r2 =(inner_rad-lid_thickness));
                }
            } 
}


module renderPotType(ptype) {
    if (ptype == "flatbottom") {
        flatBottomPot();
    } else  if (ptype == "flatbottom_with_fins") {
        flatBottomPotWithFins();
    } else if (ptype == "roundbottom") {
        roundBottomPot();
    } if (ptype == "roundbottom_with_fins") {
//        flatLid (); 
        conicalLid (); 
               roundBottomPotWithFins();
    } 
}

difference () {
    renderPotType(ptype);
    translate([200,0,0])
    cube(100,center=true);
}

//difference () {
