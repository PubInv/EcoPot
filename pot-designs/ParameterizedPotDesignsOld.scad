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

finWidth = 0.2;
finLength = outer_rad/2;
finHeight = 5;

legWidth = 0.5;
legLength = outer_rad/2;
legHeight = 5;
legBallRadius = 0.4;


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


module legFin(angle) {
    rotate([0,0,angle])
    translate([0,outer_rad-legLength/2,-outer_rad/2])
    union() {
        cube([legWidth,legLength,legHeight],center=true);
        translate([0,legLength/2,-legHeight/2])
        sphere(legBallRadius);
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
    roundBottomPot();
    difference() {
        union() {
            legFins(3);
            radialFins(12);
        }
        roundBottomOutside();
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

module renderPotType(ptype) {
    if (ptype == "flatbottom") {
        flatBottomPot();
    } else  if (ptype == "flatbottom_with_fins") {
        flatBottomPotWithFins();
    } else if (ptype == "roundbottom") {
        roundBottomPot();
    } if (ptype == "roundbottom_with_fins") {
        roundBottomPotWithFins();
    } 
}

difference () {
    renderPotType(ptype);
    translate([200,0,0])
    cube(100,center=true);
}

//difference () {
