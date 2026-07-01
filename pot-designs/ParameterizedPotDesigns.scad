

// Copyright Aditya Choksi, Cledden Obeng-Poku Kwanin, and Robert L. Read, 2024
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to make a new parametrized experimental apparatus
// for teting our ferrofluid check valve. It will be similar to the system
// that Veronica design in SolidWorks, but will use the improved, 360 degree design
VERSION = 1.01;

excess_lip_scale_factor = 1.3;

// PI = 3.141592;

USE_VERTICAL_POT_KNIFE = false;

// change these together!
POT_BOTTOM_SHAPE_FLAT = false;
// ptype = "flatbottom";
//ptype = "flatbottom_with_fins";
// ptype = "roundbottom";
//ptype = "roundbottom_with_fins";
// ptype = "roundbottom_with_handles";
// ptype = "studs";
// ptype = "roundbottom_with_fins_and_handles";
 ptype = "wavy";
// ptype = "erlenmeyer";
// ptype = "none";

//ctype = "roundBottomPot_content";
//ctype = "flatBottomPot_content";

// ctype = "erlenmeyer_content";
ctype = "none"; 
 
ltype = "none";
// ltype = "flat_lid"; // -- incorrect!
// ltype = "solidconical"; // -- incorrect!
// ltype = "hollowconical"; 
// ltype = "hollowconicalwithconcavelid";
// ltype="conicalLidErlenmeyer";
// ltype ="conicalLidIvan";
// ltype = "wavyLid";


// TODO: we need a good module for the D-handles.
// Right now that code is spread across a lot of places.

// This is the type for the adapter for testing
 ttype = "none";
// ttype = "threestone";
// ttype = "printableThreeStone";



ftype = "thin";
// ftype = "thick";
fin_sharpness_thin = 1.0;
fin_sharpness_thick = 8.0;

fin_sharpness = 1.0;

HALF_FINS = "true"; // This controls intermediary fins between the main heat transfer fins
// HALF_FINS = "false";

adapter_h_mm = 30;
adapter_r_mm = 35/2;
adapter_w_mm = 2;

// TODO: An Aspect Ratio for flat pots can be less than 1,
// but not for round-bottomed pots. We should reorganize
// the code to take that into account.


// Currently if the Aspect Ratio is <= 1.0, the bot is not defined.
//if (POT_BOTTOM_SHAPE_FLAT) {
//    A = 0.6; // aspect ratio for flat pots
//} else {
//    A = 1.3; // aspect ratio (pure number) for rounded pots
//}
C = 2.5; //curvature factor  = major_radius/minor_radius. For Erlenmeyer Pot
A = (ptype == "erlenmeyer" ||  ptype == "wavy" || POT_BOTTOM_SHAPE_FLAT) ? 0.7 : 1.3;
// A=0.7;// for erlenmeyer Pot
A_cone = A - (0.5/(C+1));
a = 0.5; // r/R 0 < a <1, r/R radius factor which is a ratio of rim radius to inner base radius
echo("A");
echo(A);

V_ml = 100;
// 1 ml = 1000 mm^3
V_water = V_ml*1000;
V_pot = ((V_ml*1000)*excess_lip_scale_factor); // cubic millimeters (thousandths of a mililter)
V_pot_ml = V_pot / 1000;


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

// This is the aspect ratio times the radius...
// This is now unclear to me
function height(A,V) = A * radius(A,V);

function side(A,V) = height(A,V) - radius(A,V);



// In this case, A = H / (2R)
// V = H * PI * R^2
// V = (A * 2R ) PI * R^2 =  2 * PI * AR^3
// R = pow(V / ( 2 * PI * A), 1/3);

function cyl_radius(A,V) = pow(V / ( 2 * PI * A), 1/3);
function cyl_height(A,V) = A*(2*cyl_radius(A,V));

inner_base_radius = pow(((V_pot)/(PI*(((2*A_cone*(1+a+pow(a,2)))/3)+(((2*pow(C,2))+(PI*C))/(2*pow(C+1,3)))))),1/3);

minor_radius = inner_base_radius/(C+1); //radius of base curvature
major_radius = C * minor_radius;

height_cone = (2*inner_base_radius)*A_cone;


echo(radius(A,V_pot));
echo(height(A,V_pot));

echo("cyl radius");
echo(cyl_radius(A,V_pot));
echo("cyl height");
echo(cyl_height(A,V_pot));

radius_mm = ptype == "erlenmeyer"?inner_base_radius: radius(A,V_pot);

tester_mm = radius_mm*2;

// This is the radius to hold the heat gun.
adapter_mm = 60;

rim_bead_radius = radius_mm/24;

// wall_thickness = radius_mm/20;
wall_thickness = (ptype == "wavy" ? radius_mm/20 : ((ptype == "erlenmeyer") ? 1.16605*pow(10,-5)*V_water  : radius_mm/30));
// for 

echo("wall_thickness");
echo(wall_thickness);
rim_radius = inner_base_radius*a;
outer_base_radius = inner_base_radius + wall_thickness;

outer_rim_radius = rim_radius + wall_thickness;

//parameters for erlenmeyer content
V_cone = PI*height_cone*(1/3)*(pow(inner_base_radius,2)+(inner_base_radius*rim_radius)+pow(rim_radius,2));
V_base = (C==0)? (1/4*PI*pow(minor_radius,2)) : (PI*((pow(major_radius,2)*(minor_radius))+(0.5*PI*major_radius*pow(minor_radius,2)))); 
E = excess_lip_scale_factor;
water_base_radius = inner_base_radius; 
water_top_radius = pow((pow(inner_base_radius,3))-((3*(V_water-V_base)*(inner_base_radius-rim_radius))/(PI*height_cone)),1/3);
water_height = (a==1)? (height_cone/E):((height_cone*(inner_base_radius-water_top_radius))/(inner_base_radius-rim_radius));
V_water_base = V_base;
V_water_cone = PI*water_height*(1/3)*(pow(inner_base_radius,2) + (inner_base_radius * water_top_radius)+(pow(water_top_radius,2)));


base_scale_factor = 2;
height_scale_factor = 0.5;
extra_height = radius_mm/40;

lid_thickness = (ltype == "wavyLid") ? radius_mm/20 : wall_thickness;
echo("lid_thickness");
echo(lid_thickness);
//lid_thickness = wall_thickness;
lid_knob_height = radius_mm/5;
knob_scale_factor = 2;
lid_wall_size = sqrt(lid_thickness);
lid_scale_factor =  0.5;

lid_hook_height = radius_mm/6;
lid_hook_gap_tolerance = radius_mm/14;
lid_hook_thickness = radius_mm/30;
lid_hook_connector_height = radius_mm/60;
lid_extender_angle_scale = 0.9;

lid_handle_radius = radius_mm*0.6;
lid_handle_thickness = radius_mm/6;
lid_handle_wall_thickness = radius_mm/40;
lid_handle_scale_factor = 1.2;


conical_lid_scale_factor = (ltype == "wavyLid") ? 0.8: 0.7;
conical_lid_height = (ltype == "wavyLid") ? radius_mm / 1.5 : (POT_BOTTOM_SHAPE_FLAT ? radius_mm/1.3 : radius_mm/0.8);

conical_end_height = radius_mm/4;
conical_end_scale_factor = 1.33;


pot_handle_radius = POT_BOTTOM_SHAPE_FLAT ? radius_mm/3 : radius_mm/2.4;
pot_handle_thickness = POT_BOTTOM_SHAPE_FLAT ? radius_mm/8 : radius_mm/6;


pot_handle_wall_thickness = radius_mm/40;
handle_position = -(radius_mm/6);

// lid_distance_from_pot = radius_mm/1.2;
lid_distance_from_pot = radius_mm/2.8;

// WAVY_POT

WAVY_LOBE = 6;


// set resolution here
$fn=120;

module roundedFin(Fw,Fl,Fh){
    color ("red")
    //cube([Fw,Fl,Fh],center=true);
    resize(newsize=[Fw,Fl,Fh])
        sphere(Fh);
}

module cubeFin(Fw,Fl,Fh){
    color ("purple")
    cube([Fw,Fl,Fh],center=true);
}


module radialFin(r,angle) {
    ro = r + wall_thickness;
    finLength = ro/2;
    finHeight = ro;
        rotate([0,0,angle])
        translate([0,ro-finLength/2,-finHeight/2])
        roundedFin(finWidth*3,finLength*1.5,finHeight);
}


module legFin(r,angle) {
    ro = r + wall_thickness;
    legLength = ro/2;
    legHeight = ro;
    rotate([0,0,angle])
    translate([0,ro-legLength/2,-ro/2])
    union() {
        //cubeFin(legWidth,legLength,legHeight);
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
module triangularFins(r,num) {
    delta = 360 / num;
    for ( i = [0:1:num-1]) {
       triangularFinMK(r,delta*i,false);
    }
    if (HALF_FINS) {
        for ( i = [0:1:num-1]) {
           triangularFinMK(r,delta*i+delta/2,true);
        }
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

        // now we add the rim and cut away a cone to make a
        // Conical fit for the rim.
        color("blue")
        difference() {
            cylinder (h=side_h,r1=radius_mm+wall_thickness,r2=radius_mm+wall_thickness);
        }
    }
}



module roundBottomPot(A,V) {
   radius_mm = radius(A,V);
   side_h = side(A,V);
    union() {
       difference() {
            roundBottomOutside(A,V);
            union () {
                sphere (r = radius_mm);
                translate([0,0,1])
                cylinder (h=side_h+1,r1 =radius_mm,
                r2= radius_mm);
            }
        }
        translate([0,0,side_h-rim_bead_radius])
        potInterface(radius_mm,radius_mm+wall_thickness,rim_bead_radius);
    }
}

module roundBottomPotWithFins(A,V) {
    radius_mm = radius(A,V);
    roundBottomPot(A,V);

    difference() {
        union() {
            legFins(radius_mm,3);
            triangularFins(radius_mm,18);
            //radialFins(radius_mm,12);
        }
        roundBottomOutside(A,V);
    }
}

module roundBottomPotWithHandles(A,V){
    radius_mm = radius(A,V);
    side_h = side(A,V);
    roundBottomPot(A,V);

    union(){
        roundBottomPot(A,V);

    handle(A,V,ptype,radius_mm);
    handle(A,V,ptype,-radius_mm);
    }
}
module roundBottomPotWithHandlesAndFins(A,V){
    radius_mm = radius(A,V);
     side_h = side(A,V);
    roundBottomPotWithFins(A,V);

    union(){
        roundBottomPotWithFins(A,V);
        handle(A,V,ptype,radius_mm);
        handle(A,V,ptype,-radius_mm);
    }
}

module flatBottomPot (A,V) {
    radius_mm = cyl_radius(A,V);
    outer_rad = cyl_radius(A,V) + wall_thickness;
    echo("outer_rad");
    echo(outer_rad);
    pot_height = cyl_height(A,V);
    union(){
        translate([0,0,pot_height/2 - rim_bead_radius])
        potInterface(radius_mm,radius_mm+wall_thickness,rim_bead_radius);
        difference () {
            cylinder (h=    pot_height, r=outer_rad, center = true);
            translate ([0,0,(wall_thickness+(extra_height/2))])
            cylinder (h=pot_height+extra_height, r1=(outer_rad-wall_thickness), r2 =(outer_rad-wall_thickness), center=true);

    }
    translate([0,0,pot_height/4]) {
        union() {
            handle(A,V,ptype,radius_mm);
            handle(A,V,ptype,-radius_mm);
        }
    }
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

module flask_cone() {
    difference() {
        cylinder (r1 = outer_base_radius, r2 = outer_rim_radius, h = height_cone);
// inner subtracted part
        union () {
 //           translate([0,0,-1])
            cylinder (r1 = inner_base_radius, r2 = rim_radius, h = height_cone);
         };
    }
}

module flask_base() {
    difference () {
        union() {
            translate([0,0,0])
            difference() {
                rotate_extrude(convexity = 10)
                translate([(major_radius), 0, 0])
                
                difference () {
                    circle (r=minor_radius+wall_thickness);
                    translate ([-(minor_radius+wall_thickness),0])
                   square (2*(minor_radius+wall_thickness));
                    translate ([-2*(minor_radius+wall_thickness),-2*(minor_radius+wall_thickness)])
                    square (2*(minor_radius+wall_thickness));
                };   
                
               rotate_extrude(convexity = 10)
                translate([(major_radius), 0, 0])
                difference () {
                    circle (r=minor_radius);
                    translate ([-(minor_radius),-0])
                    square (2*(minor_radius));
                    translate ([-2*minor_radius,-2*minor_radius])
                    square (2*(minor_radius));
                };
            }
        }
        
    }
    translate([0,0,-(minor_radius+(wall_thickness/2))])
    cylinder(h=wall_thickness,r=major_radius,center=true);
}

module flask1() {
    flask_cone();
    flask_base();
    translate ([0,0,height_cone-(rim_bead_radius)])
potInterface_erlenmeyer(rim_radius,outer_rim_radius, rim_bead_radius);
}

module erlenmeyer() {
    union() {
        flask1();
        translate([0,0,(height_cone/1.5)])
        handle_erlenmeyer(-inner_base_radius/1.5);
        translate([0,0,(height_cone/1.5)])
        handle_erlenmeyer(inner_base_radius/1.5);
        
    }
}


module flatBottomPot_content (A,V_pot,V_water) {
    outer_rad = cyl_radius(A,V_pot) + wall_thickness;
    echo("outer_rad");
    echo(outer_rad);
    // I think this is wrong...we want to use
    // the cyl_radius to compute the water...
    pot_height = cyl_height(A,V_pot);
    water_height = pot_height * V_water/V_pot;

        translate ([0,0,wall_thickness/2])
    translate([0,0,-(pot_height - water_height)/2])
    color ("blue")
        cylinder (h=(water_height-(wall_thickness)),r1 =(outer_rad-wall_thickness), r2 =(outer_rad-wall_thickness), center=true);
}


// Take the Volume here to be the true volume of water,
// which is less than the pot volume
module roundBottomPot_content(A,V_pot,V_water) {
    // We need to correct the radius here
    // for the excessive lip factor.
    // The radius must be computed from the pot volume
   radius_mm = radius(A,V_pot);

   side_water_h = height(A,V_water) - radius(A,V_pot);
   side_h = side(A,V_water);
    // if the side_h is not positive here, we likely
    // have a serious problem...we need to rethink this..

    echo("side_h");
    echo(side_h);
    echo("side_water__h");
    echo(side_water_h);
      difference () {
        union () {
            sphere (r = radius_mm);
            translate([0,0,0])
            cylinder (h=side_water_h,r1 =radius_mm,
            r2= radius_mm);
        }
        translate ([-radius_mm,-radius_mm,side_water_h])
        cube (size = radius_mm*2, center =false);
    }
}

module water_cone() {
    cylinder (r1 = water_base_radius, r2 = water_top_radius, h = water_height);
}
         
module water_base() {
    union() {
                                  rotate_extrude(convexity = 10)
                    translate([(major_radius), 0, 0])
                    difference () {
                        circle (r=minor_radius);
                        translate ([-(minor_radius),-0])
                        square (2*(minor_radius));
                        translate ([-2*minor_radius,-2*(minor_radius)])
                        square (2*(minor_radius));
                    }; 
   
    translate([0,0,-(minor_radius)/2])
    cylinder(h=(minor_radius),r=major_radius,center=true);
    };
}

module erlenmeyer_content() {
                water_base();
                water_cone();
};

module concavehandleshell (){
    radius_mm = radius(A,V_pot);
    difference(){
        scale([1,1,lid_scale_factor])
            sphere(radius_mm*conical_lid_scale_factor);

        translate([0,0,radius_mm*conical_lid_scale_factor])
        cube((radius_mm*conical_lid_scale_factor)*2, center = true);
    }
}

module conicalknob() {
    rotate ([180,0,0])
    translate ([0,0,lid_thickness*0.01])
    cylinder (h= lid_knob_height, r1=(lid_thickness),r2=lid_thickness*knob_scale_factor);
}

// This is the lip that goes into the pot.
module lidhookextender() {
    radius_mm = radius(A,V_pot);
    difference(){

        cylinder(h = lid_hook_height, r2 = radius_mm - lid_hook_gap_tolerance, r1 = (radius_mm - lid_hook_gap_tolerance)*lid_extender_angle_scale, center=true);

// This removes the core.
        cylinder(h = lid_hook_height*6, r2 = (radius_mm - lid_hook_gap_tolerance)-lid_hook_thickness, r1 = ((radius_mm - lid_hook_gap_tolerance)*lid_extender_angle_scale)-lid_hook_thickness, center=true);
    }
}
// I guess that this connects the extender to the lid.
module lidhookconnector() {
    radius_mm = radius(A,V_pot);
    difference(){
            cylinder(h = lid_hook_connector_height, r = radius_mm,center=true);
            cylinder(h = lid_hook_connector_height*6, r = (radius_mm - lid_hook_gap_tolerance)*lid_extender_angle_scale,center=true);
    }
}
// I think the idea here is to build up
module lidhook(){
    union() {
        lidhookextender();
        translate([0,0,-lid_hook_height/10])
        lidhookconnector();
    }
}


// this is the part of the pot that is a "bead" inside
// the rim of the pot strenghtening it from dings and producing
// a tight fit with the lid. The lid Interface cuts away
// the pot Interface, so that the shape need only be programmed once
// ri = pot inner radius
// ro = pot outer radius
module potInterface(ri,ro,rim_bead_radius = 10) {
    difference() {
        rotate_extrude(angle = 360, convexity = 2)
        translate([ri, 0])
        circle(r = rim_bead_radius);
      // now cutaway a cylinder of radius rotate
        difference() {
            cylinder(h=80,r=ro+rim_bead_radius,center=true);
            cylinder(h=100,r=ri,center=true);
        }
    }
}

module potInterface_erlenmeyer(ri,ro,rim_bead_radius = 10) {
    difference() {
        rotate_extrude(angle = 360, convexity = 10) 
        translate([ri, 0])
        circle(r = rim_bead_radius);
      // now cutaway a cylinder of radius rotate
        translate([0,0,-height_cone+rim_bead_radius])
        difference() {
            cylinder(h=height_cone+5,r1=outer_base_radius,r2=outer_rim_radius -((5/height_cone)*(outer_base_radius-outer_rim_radius)),center=false);
            cylinder(h=height_cone+5,r1=inner_base_radius,r2= rim_radius -((5/height_cone)*(inner_base_radius-rim_radius)),center=false);
        }
    }
}

// this is the part of the lid that strengthens the rim
// and makes a seal with the pot
// ri is the innner radius of the pot rim,
// ro is the outer radius
module lidInterface(ri,ro,rim_bead_radius = 10) {
    difference() {
        rotate_extrude(angle = 360, convexity = 2)
        translate([ri-rim_bead_radius, 0])
        circle(r = rim_bead_radius);
      // now cutaway a cylinder of radius rotate
        translate([0,0,rim_bead_radius])
        rotate_extrude(angle = 360, convexity = 2)
        translate([ri, 0])
        circle(r = rim_bead_radius);
    }
}

module lidInterface_erlenmeyer(ri,ro,rim_bead_radius = 20) {
    difference() {
        rotate_extrude(convexity = 10) 
        translate([ri-rim_bead_radius,0])
        circle(r = rim_bead_radius);
      // now cutaway a cylinder of radius rotate
        translate([0,0,rim_bead_radius])
        rotate_extrude(convexity = 10) 
        translate([ri, 0])
        circle(r = rim_bead_radius);
    }  
}

module flatLid (inner_rad) {
    outer_rad = inner_rad+wall_thickness;
    radius_mm = radius(A,V_pot);
    theta = 20;
    cr = outer_rad / sin(theta);
    y = cr * cos(theta);
    union () {
        rotate([180,0,0])
        intersection() {
            translate([0,0,-y])
            difference() {
                sphere(cr, $fn=200);
                sphere(cr-wall_thickness, $fn=200);
            }
            translate([0,0,-rim_bead_radius/8])
            cylinder(h=outer_rad*10, r = inner_rad - rim_bead_radius/2);
         };

        translate([0,0,-(-0.5 + cr-y)])
        conicalknob();
        lidInterface(inner_rad,inner_rad+wall_thickness,
                    rim_bead_radius);
                    };
}

module flatLidOrig (inner_rad) {
    outer_rad = 1.8*(inner_rad)+wall_thickness;
    union () {
    translate ([0,0,outer_rad*0.9])
    rotate ([180,0,0])
        difference () {
           intersection() {
            sphere (outer_rad, $fn=100);
            cylinder (h=outer_rad, r =outer_rad/2, center = false);
};
translate ([-outer_rad/2,-outer_rad/2,-outer_rad/8])
cube (outer_rad); }
                }


    /*outer_rad = inner_rad+wall_thickness;
    union () {
        cylinder (h= lid_thickness, r=outer_rad, center = true);*/
        // this needs to be improved.
        conicalknob();
        translate([0,0, rim_bead_radius/2])
        lidInterface(inner_rad,inner_rad+wall_thickness,
        rim_bead_radius);
}

module solidconicalLid (inner_rad) {
    outer_rad = inner_rad+wall_thickness;
    union () {
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



//Ivan
function pType(ptype) =
    ptype != "flatbottom";

echo("Ivan");
echo(pType(ptype));
distance=10.0;  //change

module conical_part (radius,height) {

    translate([0,0,lid_thickness*0.55+lidPositionZ(A,V_pot)+distance]){
    cylinder (h=(height), r1 =(radius) ,r2=(radius*conical_lid_scale_factor));
    }
}
function lidPositionZ(A,V_pot) =
    pType(ptype)
    ? side(A,V_pot)
    : cyl_height(A,V_pot)/2;

function lid_radius()=
    pType(ptype)
    ? radius_mm
    : cyl_radius(A,V_pot);

echo("Ivan");
echo(lid_radius());

module conicalLidIvan(inner_rad,A,V_pot){
      outer_rad = inner_rad + lid_thickness;
    translate([0,0,-rim_bead_radius/2]){
    union(){
    difference(){
            conical_part(outer_rad,conical_lid_height);
            translate([0,0,wall_thickness]){
            conical_part(inner_rad,conical_lid_height-wall_thickness+0.001);
            }
        }

        translate([0,0,lidPositionZ(A,V_pot)+distance+rim_bead_radius/2]){
        rotate ([180,0,0]){
        lidInterface(inner_rad,inner_rad+wall_thickness,
                    rim_bead_radius);}
            }
        }
    }
}


module conical_part_erlenmeyer (radius,height) {
    
    translate([0,0,lidPositionZ_erlenmeyer(A,V_pot)+distance]){
    cylinder (h=(height_cone), r1 =(radius) ,r2=(radius*conical_lid_scale_factor));
    }
}
function lidPositionZ_erlenmeyer(A,V_pot) = height_cone;

function lid_radius_erlenmeyer()=
     rim_radius;

module conicalLidIvan_erlenmeyer(inner_rad,A,V_pot){
      outer_rad = inner_rad + lid_thickness;
    translate([0,0,-rim_bead_radius/4]){
    union(){  
    difference(){
            conical_part_erlenmeyer(outer_rad,conical_lid_height);
            translate([0,0,lid_thickness]){
            conical_part_erlenmeyer(inner_rad,conical_lid_height-wall_thickness+0.001);
            }
        }
        
        translate([0,0,lidPositionZ_erlenmeyer(A,V_pot)+distance+rim_bead_radius/8]){
        rotate ([180,0,0]){    
        lidInterface_erlenmeyer(inner_rad,inner_rad+wall_thickness,
                    rim_bead_radius);}
            }          
        }
    }
}


// This is our main pot lid.
module concaveconicalLid(inner_rad){
    outer_rad = inner_rad+wall_thickness;
    radius_mm = radius(A,V_pot);

    union(){
        difference(){
            union () {
                difference(){
                    scale([1,1,lid_scale_factor])
                        sphere(radius_mm*conical_lid_scale_factor);
                    translate([0,0,-radius_mm*conical_lid_scale_factor])
                    cube((radius_mm*conical_lid_scale_factor)*2, center = true);
                }
                difference(){
                    cylinder (h=conical_lid_height, r1=(outer_rad*conical_lid_scale_factor), r2 =(outer_rad));
                    translate([0,0,lid_thickness*0.55])
                    // this cuts away a portion of the lid..
                    cylinder (h=conical_lid_height-lid_wall_size, r1=(outer_rad*conical_lid_scale_factor)-(lid_wall_size), r2 =(outer_rad)-(lid_wall_size));
                }
                translate([0,0,conical_lid_height])
                // This is actually the inner part of the rim that
                // fits inside the male part of the pot.
                lidInterface(radius_mm,radius_mm+wall_thickness,
                    rim_bead_radius);
            }
            scale([1,1,lid_scale_factor])
                sphere((radius_mm*conical_lid_scale_factor)-lid_wall_size);
        }

        // This is the handle
        difference(){
            union(){
                rotate([0,90,0])
                scale([lid_handle_scale_factor,1,1])
                translate([-(radius_mm*conical_lid_scale_factor)/2,0,0])
                lidhandleshell();
                translate([0,-(radius_mm*conical_lid_scale_factor)/1.8,0])
                rotate([25,0,0])
                cylinder(conical_end_height,lid_handle_thickness/2.1,(lid_handle_thickness/2)*conical_end_scale_factor);
               translate([0,(radius_mm*conical_lid_scale_factor)/1.8,0])
                rotate([-25,0,0])
                cylinder(conical_end_height,lid_handle_thickness/2.1,(lid_handle_thickness/2)*conical_end_scale_factor);
            }
            difference(){
                cylinder (h=conical_lid_height, r1=(outer_rad*conical_lid_scale_factor), r2 =(outer_rad));
                scale([1,1,lid_scale_factor])
                sphere(radius_mm*conical_lid_scale_factor);
                scale([1,1,lid_scale_factor])
                sphere((radius_mm*conical_lid_scale_factor)-lid_wall_size);
                    translate([0,0,-radius_mm*conical_lid_scale_factor])
                    cube((radius_mm*conical_lid_scale_factor)*2, center = true);
            }
        }

    }
}



module lidhandleshell (){
    rotate_extrude(angle=360) {
        //difference(){
            translate([lid_handle_radius - lid_handle_thickness/2, 0])
                circle(d=lid_handle_thickness);
            //translate([lid_handle_radius - lid_handle_thickness/2, 0])
                //circle(d=lid_handle_thickness - lid_handle_wall_thickness);
        //}
    }
}


//Ivan

module pothandleshell(x) {
  translate([0, x, 0])
  rotate_extrude(angle = 360) {

      translate([pot_handle_radius - pot_handle_thickness / 2, 0])
      circle(d = pot_handle_thickness);
  }
}

module handle(A,V,ptype,radius){
    if (ptype=="flatbottom"){
        difference(){
            pothandleshell(radius);
            cylinder(r = abs(radius), h = 20, center= true);
        }
    }
    else {
        radius_mm = radius(A, V);
        difference(){
            union(){
                pothandleshell(radius);
                //pothandleshell(-radius);
            }
            roundBottomOutside(A,V);
        }
    }
}

module pothandleshell_erlenmeyer(x) {
  translate([0, x, 0])
  rotate_extrude(angle = 360) {
    
      translate([pot_handle_radius - pot_handle_thickness / 2, 0])
      circle(d = pot_handle_thickness);
  }
}

module handle_erlenmeyer(radius){
        difference(){
//            union(){
//                //pothandleshell_erlenmeyer(-radius);
//            }
            pothandleshell_erlenmeyer(radius);
            translate([0,0,-(height_cone/1.5)])
            cylinder (r1 = outer_base_radius, r2 = outer_rim_radius, h = height_cone, center=false);
            
            
            
      }  
    }


module renderLid(ltype,r) {
    if (ltype == "flat_lid") {
        // translate ([0,0,cyl_height(A,V_pot)/1.35+lid_distance_from_pot])
        translate ([0,0,lid_distance_from_pot])
        rotate ([180,0,0])
        flatLid(radius_mm);
    } else  if (ltype == "solidconical") {
        translate ([0,0,cyl_height(A,V_pot)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        solidconicalLid(r);
    } else if (ltype == "hollowconical"){
        translate ([0,0,cyl_height(A,V_pot)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        hollowconicalLid(r);
    }  else if (ltype == "hollowconicalwithconcavelid"){
        translate ([0,0,cyl_height(A,V_pot)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        concaveconicalLid(r);
    }
    else if (ltype == "conicalLidIvan"){
            rad=lid_radius();
            conicalLidIvan(rad,A,V_pot);
     }
    else if (ltype == "conicalLidErlenmeyer"){
            rad=lid_radius_erlenmeyer();
            conicalLidIvan_erlenmeyer(rad,A,V_pot);
     }
     else if (ltype =="wavyLid") {
         rad = wavy_radius_from_volume_ml(V_pot_ml);
         translate([0,0,6])
         conicalLidIvan(rad,A,V_pot);   
     }
}

//concept
module studs(A,V){
    radius_mm = radius(A,V);
    radius_ball=radius_mm/15;
 difference () {
    union() {
        roundBottomPotWithHandles(A,V_pot);
        for (theta = [5 :10: 180]) {
            for (phi = [0 :20: 180]){
                rotate([0,phi,theta])
                translate([radius_mm,0,0])
                sphere(radius_ball);
                }
            }
        }
        sphere (r = radius_mm);
    };
}

// TODO:
// 1) Change this code so that changing t effects
// only the outside of the pot
// 2) Move all of these paramaters to the top of the file
// 3) Rename these parametes so they code they don't collide
// 4) Add a rim so that it fits our pots perfectly.
// 5) Make it possible to lenghen height of pot to
// adjust volume keeping the rim the same.

// 1. Recursive Factorial Method (for positive integers)
// Gamma(n) = (n-1)!



function x(r,theta,phi)= r*sin(theta*180/PI)*cos(phi*180/PI);
function y(r,theta,phi)= r*sin(theta*180/PI)*sin(phi*180/PI);
function z(r,theta)= r*cos(theta*180/PI);
function cartesian(theta,phi,rho) =
    [x(rho, theta, phi),
     y(rho, theta, phi),
     z(rho, theta)];

// This code for gamma function from ChatGPT
// Gamma function approximation for OpenSCAD
//
// Uses the Lanczos approximation.
// Accurate for most practical engineering/modeling purposes.
//

// Lanczos coefficients
_lanczos_p = [
    0.99999999999980993,
    676.5203681218851,
   -1259.1392167224028,
    771.32342877765313,
   -176.61502916214059,
    12.507343278686905,
   -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7
];


// Main gamma function
function gamma(z) =
    z < 0.5
    ? PI / (sin(PI * z) * gamma(1 - z))   // Reflection formula
    : _gamma_lanczos(z - 1);


// Internal Lanczos implementation
function _gamma_lanczos(z) =
    let(
        g = 7,
        x = _lanczos_sum(z),
        t = z + g + 0.5
    )
    sqrt(2 * PI) * pow(t, z + 0.5) * exp(-t) * x;


// Sum of Lanczos coefficients
function _lanczos_sum(z, i = 1, acc = _lanczos_p[0]) =
    i >= len(_lanczos_p)
    ? acc
    : _lanczos_sum(
        z,
        i + 1,
        acc + _lanczos_p[i] / (z + i)
      );


// This formula from ChatGPT for the symbolic integration
// of the formula from Desmos

//
// Volume of the spherical shape:
//
// rho(theta,phi) = r * (1 + f*cos(n*theta)*sin(2*phi)^g)
//
// Using the closed-form symbolic result:
//
// V = (PI*r^3/3) *
//     ( 2
//       + 3*f^2*2^(2g-1)
//         * Gamma(g+1)
//         * Gamma(g+1/2)
//         / Gamma(2g+3/2)
//     )
//
// Assumes:
//   - gamma(x) function already exists
//   - n is a nonzero integer
//   - g > -1/2
//
// note: generally, this is close to the volume of a hemisphere
// for f = 0.2 .
function shape_volume(r, f, g) =
    (PI * pow(r, 3) / 3) *
    (
        2
        +
        3
        * pow(f, 2)
        * pow(2, 2 * g - 1)
        * gamma(g + 1)
        * gamma(g + 0.5)
        / gamma(2 * g + 1.5)
    );


//
// Example usage
//

echo(shape_volume(10, 0.2, 3));


//
// Computes radius r in mm
// from target volume V_ml in milliliters
//
// Assumes:
//   f = 0.2
//   g = 3.0
//

function wavy_radius_from_volume_ml(V_ml) =
    let(
        V_mm3 = V_ml * 1000,

        k = PI *
            (2 + (1024 * pow(0.2, 2) / 1001))
            / 3
    )
    pow(V_mm3 / k, 1/3);


//
// Example:
// 100 mL object
//
echo("wavy_radius_from_volume 100");
echo(wavy_radius_from_volume_ml(100));


     // I think we may have to increase the radius slightly
     // here to make 100ml. Visually inspecting the roundbottom pot,
     // it looks smaller.
module wavy_pot(V,n,t) {
// WARNING! Computations depend on these being fixed, do not change them!
    WAVY_AMPLITUDE_FACTOR = 0.2;   
    g = 3.0; //becomes more square as it increases 
      
      
    f = WAVY_AMPLITUDE_FACTOR;
    r = wavy_radius_from_volume_ml(V);
    // t=2; //thickness
    grid_size=30; //divisons of hemisphere


    echo("wavy radius");
    echo(r);
    wavy_volume_ml = shape_volume(r, f, g)/1000;
    echo("wave_volume");
    echo(wavy_volume_ml);
    // We'll use the convention from here:
    // https://en.wikipedia.org/wiki/Spherical_coordinate_system
    // theta is the angle with the polar axis z
    // phi is the rotation around the polar axis z
    dtheta = (PI/2)/grid_size; //0 to 90 degrees
    dphi = (2*PI)/grid_size; //0 to 180 degrees

    function wavy_pot_inner_norm(theta,phi) = 
        (1 + f*cos(n*phi*180/PI)* pow(sin(2*theta*180/PI), g));
    function wavy_pot_outer(theta,phi) = 
        (r+t)*wavy_pot_inner_norm(theta,phi); 
    function wavy_pot_inner(theta,phi) = 
        (r)*wavy_pot_inner_norm(theta,phi);
        
    function x(r,theta,phi)= r*sin(theta*180/PI)*cos(phi*180/PI);
    function y(r,theta,phi)= r*sin(theta*180/PI)*sin(phi*180/PI);
    function z(r,theta)= r*cos(theta*180/PI);

    prism_faces_1 = [[3,2,5],[4,0,1],[0,2,1],[2,3,1],[1,3,4],[3,5,4],[5,2,4],[2,0,4]];
    prism_faces_2 = [[4,5,1],[2,0,3],[5,4,2],[2,3,5],[4,1,0],[0,2,4],[1,5,3],[3,0,1]];
    
    cv = 0;
    rotate([180,0,0])
    union() {
    union() {
        for(i = [0 : grid_size - 1]) {
            for(j = [0 : grid_size - 1]) {
            
                theta0 = i*dtheta;
                phi0 = j*dphi;
                theta1 = (i + 1)*dtheta;
                phi1 = (j + 1)*dphi;

                i00 = cartesian(theta0,phi0,wavy_pot_inner(theta0, phi0));
                i01 = cartesian(theta0,phi1,wavy_pot_inner(theta0, phi1)); 
                i10 = cartesian(theta1,phi0,wavy_pot_inner(theta1, phi0));
                i11 = cartesian(theta1,phi1,wavy_pot_inner(theta1, phi1)); 
     // this can be used to compute the volume, as a thin frustrum.
     // The shape from the origin to the quadrilateral at 
     // these 4 points is the contribution of this. This is a
     // little trickey to do in OpenSCAD without building an 
     // overly large structure.
     // Of course, we could always to try to integrate the functions
     // above symbolically. - rlr
    
    
                o00 = cartesian(theta0,phi0,wavy_pot_outer(theta0, phi0));
                o01 = cartesian(theta0,phi1,wavy_pot_outer(theta0, phi1)); 
                o10 = cartesian(theta1,phi0,wavy_pot_outer(theta1, phi0));
                o11 = cartesian(theta1,phi1,wavy_pot_outer(theta1, phi1));     
                   
                polyhedron(
                        points=[
                        i00,
                        i10,
                        o00,
                        o10,
                        i11,
                        o11],
                        faces=prism_faces_1
                    ); //Creates half of the square cell with thickness

                polyhedron(
                        points=[
                        i00,
                        o00,
                        i01,
                        i11,
                        o01,
                        o11],
                        faces=prism_faces_2 //Completes the square by filling the other triangle.
                    );
            }
        }
    }

    // Add the rim
    translate([0,0,rim_bead_radius])
    potInterface(r,r+t,rim_bead_radius);
    // Add the handles
    translate([0,0,r/8])
    difference() {
        union() {
            pothandleshell(r);
            pothandleshell(-r);
        }
        cylinder(h=r,r=r, center = true);
    }
    }
}


module renderPotType(ptype) {
    if (ptype == "flatbottom") {
        r = cyl_radius(A,V_pot);
        renderLid(ltype,r);
        flatBottomPot(A,V_pot);
    } else  if (ptype == "flatbottom_with_fins") {
        r = cyl_radius(A,V_pot);
        renderLid(ltype,r);
        flatBottomPotWithFins(A,V_pot);
    } else if (ptype == "roundbottom") {
        r = radius(A,V_pot);
        renderLid(ltype,r);
        roundBottomPot(A,V_pot);
    } else if (ptype == "roundbottom_with_fins") {
        r = radius(A,V_pot);
        renderLid(ltype,r);
        roundBottomPotWithFins(A,V_pot);
    } else if (ptype == "roundbottom_with_handles"){
        r = radius(A,V_pot);
        renderLid(ltype,r);
        roundBottomPotWithHandles(A,V_pot);
    } else if (ptype ==         "roundbottom_with_fins_and_handles"){
        r = radius(A,V_pot);
        renderLid(ltype,r);
        roundBottomPotWithHandlesAndFins(A,V_pot);
    } else if (ptype == "studs") {
        r = radius(A,V_pot);
        renderLid(ltype,r);
        studs(A,V_pot);
    } else if (ptype =="wavy") {   
        wavy_pot(V_pot_ml,WAVY_LOBE,wall_thickness);
    } else if (ptype =="erlenmeyer") {
        erlenmeyer();
    } else if (ptype == "none"){

    }

}


module renderContentType(ctype) {
    if (ctype == "flatBottomPot_content") {
         scale (1)
         flatBottomPot_content(A,V_pot,V_water);
    } else  if (ctype == "roundBottomPot_content") {
        scale (1)    roundBottomPot_content(A,V_pot,V_water);
    }  else  if (ctype == "erlenmeyer_content") {
    erlenmeyer_content();
      
    }  else if (ctype == "none"){

    }
}


if (USE_VERTICAL_POT_KNIFE) {
    difference() {
        renderLid(ltype,radius(A,V_pot));
        translate([500,0,0])
        cube([1000,1000,1000],center = true);
    }
} else {
 renderLid(ltype,radius(A,V_pot));
}


if (USE_VERTICAL_POT_KNIFE) {
    difference() {
        renderPotType(ptype);
        translate([500,0,0])
        cube([1000,1000,1000],center = true);
    }
} else {
 renderPotType(ptype);
}

renderContentType(ctype);




module triangularFin(){
    linear_extrude(height = finWidth, center = true, convexity = 10, slices = 20, scale = 1.0, $fn = 16)
        difference(){
            offset(r=10)
            polygon(points=[[0,0],[100,0],[100,100]]);
            translate([0,100,0])
            circle(100,$fn=64);
        }

}

module translate_children(){
    for(i=[0:$children-1])
        translate([200,0,0])
        children(i);
    }




module triangularFinMK(r,angle,small){
    radius_mm = radius(A,V_pot);
    //radius_divisor = 30;
    radius_divisor = 100;
    //translate([0,-radius_mm,0])
    rotate([0,-90,angle])
    translate([-radius_mm,0,0])
    difference(){
        minkowski(){
           sphere(radius_mm/radius_divisor);
           sharpFin(small);
        }
        translate([radius_mm,0,0])
        sphere(radius_mm,$fn=24);
    }
}


module sharpFin (small){
    if (ftype == "thin") {
        thickener = fin_sharpness_thin;
    } else {
        thickener = fin_sharpness_thick;
    }
//    thickener = fin_sharpness;
    radius_mm = radius(A,V_pot);
    fw = finWidth*(
        (ftype == "thin")? fin_sharpness_thin :            fin_sharpness_thick);
    knife_thickness = radius_mm/2.4;
    z = fw/2+knife_thickness/2;
    //z=30;
    theta = atan2(fw/2,radius_mm*sqrt(2));
    if (!small) {
        difference(){
            linear_extrude(height = fw, center = true, convexity = 10, slices = 20, scale = 1.0, $fn = 16)
            offset(r=0)
            polygon(points=[[0,0],[0,radius_mm],[radius_mm,radius_mm]]);
            translate([0,0,z])
            translate([radius_mm,0,0])
            rotate(theta,[-1,-1,0])
            cube([radius_mm+220,radius_mm+220,knife_thickness],center=true);
            translate([0,0,-z])
            translate([radius_mm,0,0])
            rotate(-theta,[-1,-1,0])
            cube([radius_mm+220,radius_mm+220,knife_thickness],center=true);
            }
    } else {
        f = 2;
        difference(){
            linear_extrude(height = fw/8, center = true, convexity = 10, slices = 20, scale = 1.0, $fn = 16)
            offset(r=0)
            polygon(points=[[0,0],[radius_mm/3,radius_mm],[radius_mm,radius_mm]]);
            translate([0,0,z])
            translate([radius_mm,0,0])
            rotate(theta,[-1,-1,0])
            cube([radius_mm+220,radius_mm+220,knife_thickness],center=true);
            translate([0,0,-z])
            translate([radius_mm,0,0])
            rotate(-theta,[-1,-1,0])
            cube([radius_mm+220,radius_mm+220,knife_thickness],center=true);
            }
    }
}


if (ptype == "flatbottom") {
    rim_bead_radius = lid_thickness;
} else {
    rim_bead_radius = min(3,side(A,V_pot));
}
echo("rim_bead_radius");
echo(rim_bead_radius);

finWidth = wall_thickness;
// finLength = outer_rad/2;
// finHeight = 5;

legWidth = wall_thickness;
// legLength = outer_rad/2;
// legHeight = 5;
legBallRadius = radius_mm/10;

if (ptype == "flatbottom") {
    rim_bead_radius = lid_thickness;
} else {
    rim_bead_radius = min(3,side(A,V_pot));
}
echo("rim_bead_radius");
echo(rim_bead_radius);

if (ttype == "threestone") {
    // tester_mm The adapter radius
    stone_center_r = tester_mm;
    fill_factor = 0.8;
    brace_mm = 100;
    brace_w_mm = 15;
    translate([0,0,-tester_mm/2])

    difference() {
        union() {
            union() {
                    translate([0,-(adapter_r_mm+brace_mm/2),0])
                    cube([brace_w_mm,brace_mm,brace_w_mm],center=true);

                    rotate([0,0,120])
                    translate([0,-(adapter_r_mm+brace_mm/2),0])
                    cube([brace_w_mm,brace_mm,brace_w_mm],center=true);

                    rotate([0,0,-120])
                    translate([0,-(adapter_r_mm+brace_mm/2),0])
                    cube([brace_w_mm,brace_mm,brace_w_mm],center=true);
            }

            difference() {
                cylinder(adapter_h_mm,
                        adapter_r_mm+adapter_w_mm,
                        adapter_r_mm+adapter_w_mm,
                        center=true);
                cylinder(adapter_h_mm*2,
                        adapter_r_mm,
                        adapter_r_mm,
                        center=true);
            }
            intersection() {
                cylinder(h=tester_mm*10,r=tester_mm,center=true);

                color("brown")
                union() {
                    translate([0,-stone_center_r,0])
                    sphere(r = tester_mm*fill_factor);

                    rotate([0,0,120])
                    translate([0,-stone_center_r,0])
                    sphere(r = tester_mm*fill_factor);

                    rotate([0,0,-120])
                    translate([0,-stone_center_r,0])
                    sphere(r = tester_mm*fill_factor);
                }
            }
        }
        translate([0,0,-tester_mm*5])
        cylinder(h=tester_mm*10,r=tester_mm*10,center=true);
    }

    // This is the radius to hold the heat gun.
    // adapter_mm

} else if (ttype =="printableThreeStone") {
// I'm now going to attempt to make a cone on top of a cylinder
// with three radial cuts for the purpose of attempting to make
// 3D-printable test apparatus.
// I will add the heatgun adapter as module separately....
    cylinder_inner_radius_mm = 20;
    cylinder_wall_mm = 2;
    cylinder_height_mm = 25;
    cone_large_radius_mm = 30;
    cone_height_mm = 30;
    cone_wall_mm = 2;

    difference() {
    // first, put the cylinder with its top at the origin.
    union() {
    translate([0,0,-cylinder_height_mm/2])
    difference() {
                cylinder(cylinder_height_mm,
                        cylinder_inner_radius_mm+cylinder_wall_mm,
                        cylinder_inner_radius_mm+cylinder_wall_mm,
                        center=true);
                translate([0,0,cylinder_wall_mm])
                cylinder(cylinder_height_mm,
                        cylinder_inner_radius_mm,
                        cylinder_inner_radius_mm,
                        center=true);
            }
     translate([0,0,cone_height_mm/2])
     difference() {
                cylinder(cone_height_mm,
                        cylinder_inner_radius_mm+cylinder_wall_mm,
                        cone_large_radius_mm+cone_wall_mm,
                        center=true);
                cylinder(cone_height_mm+0.5,
                        cylinder_inner_radius_mm,
                        cone_large_radius_mm,
                        center=true);
     }
     }
     color("red")
    cylinder(h = cone_height_mm+1,
            r1 = 1.5*cylinder_inner_radius_mm+1, r2=cone_large_radius_mm *2 +1, $fn = 3);
            }


} else {
}
