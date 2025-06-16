

// Copyright Aditya Choksi, Cledden Obeng-Poku Kwanin, and Robert L. Read, 2024
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to make a new parametrized experimental apparatus
// for teting our ferrofluid check valve. It will be similar to the system
// that Veronica design in SolidWorks, but will use the improved, 360 degree design


excess_lip_scale_factor = 1.3;

PI = 3.141592;

// TODO: we need a good module for the D-handles.
// Right now that code is spread across a lot of places.

// TODO: An Aspect Ratio for flat pots can be less than 1,
// but not for round-bottomed pots. We should reorganize 
// the code to take that into account.

// Currently if the Aspect Ratio is <= 1.0, the bot is not defined.
// A = 1.3; // aspect ratio (pure number) for rounded pots
A = 0.5; // aspect ratio for flat pots
V_ml = 100; 
// 1 ml = 1000 mm^3
V_water = V_ml*1000;
V_pot = ((V_ml*1000)*excess_lip_scale_factor); // cubic millimeters (thousandths of a mililter)

//Math by Ivan

// V= height*width*depth
//depth=width=a
//A=height/depth
// h= a*A
// V = a^2 * (A*a)
// a = (V/A)^(1/3)




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

//Ivan
function width_rectangle(A,V) = pow(V/A, (1/3));
function height_rectangle(A,V) = A*pow(V/A, (1/3));



echo(radius(A,V_pot));
echo(height(A,V_pot));

echo("cyl radius");
echo(cyl_radius(A,V_pot));
echo("cyl height");
echo(cyl_height(A,V_pot));

radius_mm = radius(A,V_pot);

wall_thickness = radius_mm/20;

base_scale_factor = 2;
height_scale_factor = 0.5;
extra_height = radius_mm/40;

lid_thickness = radius_mm/12;
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


conical_lid_scale_factor = 0.7;
conical_lid_height = radius_mm/0.8;

conical_end_height = radius_mm/4;
conical_end_scale_factor = 1.33;

pot_handle_radius = radius_mm/2.4;
pot_handle_thickness = radius_mm/6;
pot_handle_wall_thickness = radius_mm/40;
handle_position = -(radius_mm/6);

// lid_distance_from_pot = radius_mm/1.2;
lid_distance_from_pot = radius_mm/2.8;


finWidth = wall_thickness;
// finLength = outer_rad/2;
// finHeight = 5;

legWidth = wall_thickness;
// legLength = outer_rad/2;
// legHeight = 5;
legBallRadius = radius_mm/10;

//ptype = "rectangular";
//ptype = "flatbottom";
//ptype = "flatbottom_with_fins";
//ptype = "roundbottom";
//ptype = "roundbottom_with_fins";
//ptype = "roundbottom_with_handles";
//ptype = "roundbottom_with_fins_and_handles";
 ptype = "none";
rim_bead_radius = lid_thickness;
if (ptype == "flatbottom") {
    rim_bead_radius = lid_thickness;
} else {
    rim_bead_radius = min(3,side(A,V_pot));
}
echo("rim_bead_radius");
echo(rim_bead_radius);

 ltype = "none";
// ltype = "flat_lid"; // -- incorrect!
// ltype = "solidconical"; // -- incorrect!
// ltype = "hollowconical"; 
// ltype = "hollowconicalwithconcavelid";



//ctype = "rectangular_content"; 

 //ctype = "roundBottomPot_content"; //added by Cleddden for Pot content
// ctype = "flatBottomPot_content";//added by Cleddden for Pot content
ctype = "none"; //added by Cleddden for Pot content

// set resolution here
$fn=30;

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
       triangularFinMK(r,delta*i);
    }
}


module rectangularPotOutside(A,V,wall_thickness){
        w=width_rectangle(A,V);
        h=height_rectangle(A,V);
    
        cube([w+wall_thickness, w+wall_thickness, h+wall_thickness], center=true); 
}


module rectangularPot(A,V_pot,wall_thickness){
    difference(){
    rectangularPotOutside(A,V_pot,wall_thickness);
     translate([0,0,wall_thickness])
    rectangularPotOutside(A,V_pot,0);
    }
}

module rectangularPotContent(A,V,V_water,wall_thickness){
    w_content=width_rectangle(A,V);
    h=height_rectangle(A,V);
    h_content=V_water/(w_content^2);
    union(){
    color("blue")
    translate([-w_content/2,-w_content/2,-h/2])
    cube([w_content, w_content, h_content]); 
    
    }
    
}


rectangularPot(A,V_pot,wall_thickness);
rectangularPotContent(A,V_pot,V_water,wall_thickness);

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



module roundBottomPot(A,V,wall_thickness) {
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
    #union(){
        translate([0,0,pot_height/2 - rim_bead_radius])
        potInterface(radius_mm,radius_mm+wall_thickness,rim_bead_radius);
        difference () {
            cylinder (h=    pot_height, r=outer_rad, center = true);
            translate ([0,0,(wall_thickness+(extra_height/2))])
            cylinder (h=pot_height+extra_height, r1=(outer_rad-wall_thickness), r2 =(outer_rad-wall_thickness), center=true);
        
    }
    handle(A,V,ptype,radius_mm);
    handle(A,V,ptype,-radius_mm);
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

//this module was added by Cledden
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

//this module was added by Cledden
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

module flatLid (inner_rad) {
    outer_rad = inner_rad+wall_thickness;
    union () {
        cylinder (h= lid_thickness, r=outer_rad, center = true);
        // this needs to be improved.
        conicalknob();
        translate([0,0, rim_bead_radius/2])
        lidInterface(inner_rad,inner_rad+wall_thickness,
        rim_bead_radius);
     } 
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


module renderLid(ltype,r) {
    if (ltype == "flat_lid") {
        translate ([0,0,cyl_height(A,V_pot)/1.35+lid_distance_from_pot])
        rotate ([180,0,0])
        flatLid(cyl_radius(A,V_pot));  
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
    } else if (ptype == "roundbottom_with_fins_and_handles"){
        r = radius(A,V_pot);
        renderLid(ltype,r);
        roundBottomPotWithHandlesAndFins(A,V_pot);    
    }else if (ptype == "rectangular"){
        r = radius(A,V_pot);
        renderLid(ltype,r);
        rectangularPot(A,V_pot,wall_thickness); 
    }else if (ptype == "none"){
        
    }
}

//this module was added by Cledden
module renderContentType(ctype) {
    if (ctype == "flatBottomPot_content") {      
         scale (1)   flatBottomPot_content(A,V_pot,V_water);
    } else  if (ctype == "roundBottomPot_content") {
        scale (1)    roundBottomPot_content(A,V_pot,V_water);
    } else  if (ctype == "rectangular_content") {
        scale (1)    rectangularPotContent(A,V_pot,V_water,wall_thickness);
    }else if (ctype == "none"){
            
    }
}


 renderLid(ltype,radius(A,V_pot));
 renderPotType(ptype);
 renderContentType(ctype);//added by Cledden for the pot content




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
    



module triangularFinMK(r,angle){
    radius_mm = radius(A,V_pot);
    //translate([0,-radius_mm,0])
    rotate([0,-90,angle])
    translate([-radius_mm,0,0])
    difference(){
        minkowski(){
            sphere(radius_mm/30);
           sharpFin();
        }
        translate([radius_mm,0,0])
        sphere(radius_mm,$fn=24);
    }
}

//translate_children(){
//triangularFinMK();
//sharpFin();
//}


module sharpFin (){
    thickener = 1;
    radius_mm = radius(A,V_pot);
    fw = finWidth*thickener;
    knife_thickness = radius_mm/2.4;
    z = fw/2+knife_thickness/2;
    //z=30;
    theta = atan2(fw/2,radius_mm*sqrt(2));
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
}



