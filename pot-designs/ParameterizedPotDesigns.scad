

// Copyright Cledden Obeng-Poku Kwanin and Robert L. Read, 2024
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to make a new parametrized experimental apparatus
// for teting our ferrofluid check valve. It will be similar to the system
// that Veronica design in SolidWorks, but will use the improved, 360 degree design


wall_thickness =3;

base_scale_factor = 2;
height_scale_factor = 0.5;
extra_height = 3;

lid_thickness =20;
lid_knob_height = 15;
knob_scale_factor = 2;
lid_wall_size = sqrt(lid_thickness);

lid_hook_height = 20;
lid_hook_gap_tolerance = 10;
lid_hook_thickness = 4;
lid_hook_connector_height = 2;

conical_lid_scale_factor = 0.6;
conical_lid_height = 150;

pot_handle_radius = 40;
pot_handle_thickness = 15;
handle_height = 0;

lid_distance_from_pot = 100;

finWidth = wall_thickness;
// finLength = outer_rad/2;
// finHeight = 5;

legWidth = wall_thickness;
// legLength = outer_rad/2;
// legHeight = 5;
legBallRadius = 10;

PI = 3.141592;

// Currently if the Aspect Ratio is <= 1.0, the bot is not defined.
A = 1.3; // aspect ratio (pure number)
V = 8*1000*1000; // cubic millimeters
// This math done by Cledden...
// H = heigh will be a computed value
// S = height of the side 

// R = radius of the pot (mm)
// D = diaeter of the pot
// A = H/D
// H = R + S
// D = 2R
// VP = Vcy + Vhs (Total volume volume of hemisphere + volume of cylinder
// VP = PI * R^2 * (H - R) + 2/3 * PI * R^3
// ... collecting PI * R^2
// VP = PI * R^2 [(H-R) + 2/3 * R]
// ... substitute H = A * R
// VP = PI * R^2 [(A*R - R) + 2/3 *R]
// VP = PI * R^3 [(A - 1) + 2/3]
// VP = PI * R^3 [A - 1/3]
// R = pow(VP / (PI *(A - 1/3)),1/3)


function radius(A,V) = pow(V / (PI *(A - 1/3)),1/3);

function height(A,V) = A * radius(A,V);

function side(A,V) = height(A,V) - radius(A,V);

// In this case, A = H / (2R)
// V = H * PI * R^2 
// V = (A * 2R ) PI * R^2 =  2 * PI * AR^3
// R = pow(V / ( 2 * PI * A), 1/3);

function cyl_radius(A,V) = pow(V / ( 2 * PI * A), 1/3);
function cyl_height(A,V) = A*(2*cyl_radius(A,V));

echo(radius(A,V));
echo(height(A,V));

echo(cyl_radius(A,V));
echo(cyl_height(A,V));



// ptype = "flatbottom";
// ptype = "flatbottom_with_fins";
// ptype = "roundbottom";
//ptype = "roundbottom_with_fins";
 ptype = "roundbottom_with_handles";

// ltype = "none";
//ltype = "flat_lid";
// ltype = "solidconical";
ltype = "hollowconical";

// set resolution here
$fn=40;

module radialFin(r,angle) {
    ro = r + wall_thickness;
    finLength = ro/2;
    finHeight = ro;
    rotate([0,0,angle])
    translate([0,ro-finLength/2,-finHeight/2])
    cube([finWidth,finLength,finHeight],center=true);
}


module legFin(r,angle) {
    ro = r + wall_thickness;
    legLength = ro/2;
    legHeight = ro;
    rotate([0,0,angle])
    translate([0,ro-legLength/2,-ro/2])
    union() {
        cube([legWidth,legLength,legHeight],center=true);
        translate([0,legLength/2 - legBallRadius,-legHeight/2])
        sphere(legBallRadius);
    }
}


module radialFins(r,num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       radialFin(r,delta*i);
    }
}
module legFins(r,num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       legFin(r,delta*i);
    }
}
module roundBottomOutside(A,V) {
    radius_mm = radius(A,V);
    side_h = side(A,V);
     union () {
        color ("green")
        difference() {
            sphere (radius_mm+wall_thickness);
            translate([0,0,radius_mm*2])
            cube(radius_mm*4,center=true);
        }
        color("blue")
        cylinder (h=side_h,r1=radius_mm+wall_thickness,r2=radius_mm+wall_thickness);
    }
}
module roundBottomPot(A,V) {
   radius_mm = radius(A,V);
   side_h = side(A,V);
   difference() {    
        roundBottomOutside(A,V);
        union () {
            sphere (r = radius_mm);
            translate([0,0,1])
            cylinder (h=side_h+1,r1 =radius_mm, 
            r2= radius_mm);
        }
    }
}

module roundBottomPotWithFins(A,V) {
    radius_mm = radius(A,V);
    roundBottomPot(A,V);

    difference() {
        union() {
            legFins(radius_mm,3);
            radialFins(radius_mm,12);
        }
        roundBottomOutside(A,V);
    }
}

module roundBottomPotWithHandles(A,V){
    radius_mm = radius(A,V);
     side_h = side(A,V);
    roundBottomPotWithFins(A,V);
    
    union(){
        roundBottomPotWithFins(A,V);
        difference(){
            translate([-radius_mm-wall_thickness+0.01,0,handle_height])
                leftpothandle();
        cylinder (h=side_h,r1=radius_mm+wall_thickness,r2=radius_mm+wall_thickness,center=true);
        }
        difference(){
        translate([radius_mm+wall_thickness-0.01,0,handle_height])
            rightpothandle();
        cylinder (h=side_h,r1=radius_mm+wall_thickness,r2=radius_mm+wall_thickness,center=true);
        }
    }
}

module flatBottomPot (A,V) {
    outer_rad = cyl_radius(A,V) + wall_thickness;
    echo("outer_rad");
    echo(outer_rad);
    pot_height = cyl_height(A,V);
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

module conicalknob() {
    rotate ([180,0,0])
    translate ([0,0,lid_thickness*0.01])
    cylinder (h= lid_knob_height, r1=(lid_thickness),r2=lid_thickness*knob_scale_factor);
}

module lidhookextender() {
    radius_mm = radius(A,V);
    difference(){

        cylinder(h = lid_hook_height, r = radius_mm - lid_hook_gap_tolerance,center=true);

        cylinder(h = lid_hook_height*6, r = (radius_mm - lid_hook_gap_tolerance)-lid_hook_thickness,center=true);
    }
}

module lidhookconnector() {
        radius_mm = radius(A,V);
    difference(){
        
            cylinder(h = lid_hook_connector_height, r = radius_mm,center=true);
            cylinder(h = lid_hook_connector_height*6, r = (radius_mm - lid_hook_gap_tolerance),center=true);
    }
}

module lidhook(){
    union() {
        lidhookextender();
        translate([0,0,-lid_hook_height/10])
        lidhookconnector();
    }
}

module flatLid (inner_rad) {
    outer_rad = inner_rad+wall_thickness;
    union () {
        cylinder (h= lid_thickness, r=outer_rad, center = true);
        conicalknob();
        difference () {
            cylinder (h=lid_thickness*2, r1=(inner_rad), r2 =(inner_rad));    
            cylinder (h=(lid_thickness+extra_height), r1=(inner_rad-lid_thickness), r2 =(inner_rad-lid_thickness));
        }
     } 
}

module solidconicalLid (inner_rad) {
    outer_rad = inner_rad+wall_thickness;
    union () {
//        cylinder (h=lid_thickness, r=outer_rad, center = true);
          conicalknob();
          cylinder (h=conical_lid_height, r1=(outer_rad*conical_lid_scale_factor), r2 =(outer_rad));  
          translate([0,0,conical_lid_height])
          lidhook(); 
     } 
}


module hollowconicalLid (inner_rad) {
    outer_rad = inner_rad+wall_thickness;
    union () {
//        cylinder (h=lid_thickness, r=outer_rad, center = true);
        conicalknob();
        difference(){
            cylinder (h=conical_lid_height, r1=(outer_rad*conical_lid_scale_factor), r2 =(outer_rad));
            translate([0,0,lid_thickness*0.55])
            cylinder (h=conical_lid_height-lid_wall_size, r1=(outer_rad*conical_lid_scale_factor)-(lid_wall_size), r2 =(outer_rad)-(lid_wall_size));
        }
        translate([0,0,conical_lid_height])
        lidhook();
     }
}

module pothandleshell (){
    rotate_extrude(angle=360) {
        difference(){
            translate([pot_handle_radius - pot_handle_thickness/2, 0])
                circle(d=pot_handle_thickness);
            translate([pot_handle_radius - pot_handle_thickness/2, 0])
                circle(d=pot_handle_thickness - 1);
        }
    }
}


module leftpothandle(){
        pothandleshell();

}


module rightpothandle(){
    rotate([0,180,0])
        leftpothandle();
}


module renderLid(ltype,r) {
    if (ltype == "flat_lid") {

        translate ([0,0,cyl_height(A,V)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        flatLid(r);  
    } else  if (ltype == "solidconical") {
        translate ([0,0,cyl_height(A,V)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        solidconicalLid(r);  
    } else if (ltype == "hollowconical"){
        translate ([0,0,cyl_height(A,V)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        hollowconicalLid(r);
    }
}

module renderPotType(ptype) {
    if (ptype == "flatbottom") {
        r = cyl_radius(A,V);
        renderLid(ltype,r);
        flatBottomPot(A,V);
    } else  if (ptype == "flatbottom_with_fins") {
        r = cyl_radius(A,V);
        renderLid(ltype,r);
        flatBottomPotWithFins(A,V);
    } else if (ptype == "roundbottom") {
        r = radius(A,V);
        renderLid(ltype,r);
        roundBottomPot(A,V);
    } else if (ptype == "roundbottom_with_fins") {
        r = radius(A,V);
        renderLid(ltype,r);
        roundBottomPotWithFins(A,V);
    } else if (ptype == "roundbottom_with_handles"){
        r = radius(A,V);
        renderLid(ltype,r);
        roundBottomPotWithHandles(A,V);
    }
}

difference () {
    renderPotType(ptype);
    translate([500,0,0])
    cube(100,center=true);
}

//difference () {


