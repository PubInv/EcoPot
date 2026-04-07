//updated 20th March, 2026


PI = 3.141592;


//V_pot = V_water * excess_lip_scale_factor
//V_ml = 100
//V_water = V_ml * 1000 (mm^3)

// Volume of water in mL
V_ml = 100;
V_water = V_ml * 1000; //cubic millimeters

// Shape ratios

A_pot = 1; //Ratio of pot height to the base radius of pot
// Note: C of less than 0.2 fails in this construction...
C = 0.5; //curvature factor  = major_radius/minor_radius. PS: 1.05 was the original setting.

A = A_pot - (0.5/(C+1));   // A = h / (2*R) this is defined only for the frustrum
echo("A");
echo(A);

excessLipScale = 1.3; 

a = 0.5; // r/R 0 < a <1, r/R radius factor which is a ratio of rim radius to inner base radius  

// Pot volume with lip
V_pot = V_water * excessLipScale;

inner_base_radius = pow(((V_pot)/(PI*(((2*A*(1+a+pow(a,2)))/3)+(((2*pow(C,2))+(PI*C))/(2*pow(C+1,3)))))),1/3);
//pow(((V_pot)/(PI*((((2*A)/3)*(pow(a,2)+a+1))+((pow((1+(0.5*PI)CC-1),2)+(2*PI*C))/(pow((C+1),3)))))),1/3); //widest radius of the erlenmeyer flask
minor_radius = inner_base_radius/(C+1); //radius of base curvature
major_radius = C * minor_radius;

height = (2*inner_base_radius)*A;
wall_thickness = inner_base_radius/20; //wall thickness


//outer_base_radius = major_radius + minor_radius; 


rim_radius = inner_base_radius*a;
outer_base_radius = inner_base_radius + wall_thickness;//(outer_base_radius*(height-wall_thickness))/height;

outer_rim_radius = rim_radius + wall_thickness;

//parameters for water
V_cone = PI*height*(1/3)*(pow(inner_base_radius,2)+(inner_base_radius*rim_radius)+pow(rim_radius,2));//PI*A*2/3*pow(inner_base_radius,3)*(1+a+pow(a,2));
V_base = (C==0)? (1/4*PI*pow(minor_radius,2)) : (PI*((pow(major_radius,2)*(minor_radius))+(0.5*PI*major_radius*pow(minor_radius,2)))); //(PI*pow(C-1,2)*pow(inner_base_radius,3)/pow(C+1,3))+(2*pow(PI,2)*C*pow(inner_base_radius,3)/pow(C+1,3));//volume of curved base of pot
E = excessLipScale;
water_base_radius = inner_base_radius; 
water_top_radius = pow((pow(inner_base_radius,3))-((3*(V_water-V_base)*(inner_base_radius-rim_radius))/(PI*height)),1/3);
water_height = (a==1)? (height/E):((height*(inner_base_radius-water_top_radius))/(inner_base_radius-rim_radius));
V_water_base = V_base;
V_water_cone = PI*water_height*(1/3)*(pow(inner_base_radius,2) + (inner_base_radius * water_top_radius)+(pow(water_top_radius,2)));
V_water_model = V_water_base + V_water_cone;
V_pot_model = V_base + V_cone;
    echo("V_water_model",V_water_model,"V_pot_model", V_cone+V_base,"V_base",V_base,"V_pot",V_pot,"Difference",V_pot-V_pot_model,"inner_base_radius", inner_base_radius,"water_base_radius",water_base_radius,"water_top_radius",water_top_radius,"rim_radius",rim_radius,"water_height",water_height,"height",height,"A_pot",(height+minor_radius)/(2*inner_base_radius));

//*******Lid Related Parameters*******

lid_thickness = wall_thickness;
lid_knob_height = inner_base_radius/5;
knob_scale_factor = 2;
lid_wall_size = sqrt(lid_thickness);
lid_scale_factor =  0.5;

lid_hook_height = inner_base_radius/6;
lid_hook_gap_tolerance = inner_base_radius/14;
lid_hook_thickness = inner_base_radius/30;
lid_hook_connector_height = inner_base_radius/60;
lid_extender_angle_scale = 0.9;

lid_handle_radius = inner_base_radius*0.6;
lid_handle_thickness = inner_base_radius/6;
lid_handle_wall_thickness = inner_base_radius/40;
lid_handle_scale_factor = 1.2;

POT_BOTTOM_SHAPE_FLAT = true;
conical_lid_scale_factor = 0.7;
conical_lid_height =POT_BOTTOM_SHAPE_FLAT ? inner_base_radius/1.3 : inner_base_radius/0.8;

conical_end_height = inner_base_radius/4;
conical_end_scale_factor = 1.33;


pot_handle_radius = POT_BOTTOM_SHAPE_FLAT ? inner_base_radius/3 : inner_base_radius/2.4;
pot_handle_thickness = POT_BOTTOM_SHAPE_FLAT ? inner_base_radius/8 : inner_base_radius/6;


pot_handle_wall_thickness = inner_base_radius/40;
handle_position = -(inner_base_radius/6);

// lid_distance_from_pot = inner_base_radius/1.2;
lid_distance_from_pot = inner_base_radius/2.8;
rim_bead_radius = inner_base_radius/24;
//************************************       
    
USE_VERTICAL_KNIFE = true;


module flask_cone() {
    difference() {
        cylinder (r1 = outer_base_radius, r2 = outer_rim_radius, h = height, $fn=100);
// inner subtracted part
        union () {
 //           translate([0,0,-1])
            cylinder (r1 = inner_base_radius, r2 = rim_radius, h = height, $fn=100);
         };
    }
}

module flask_base() {
    difference () {
        union() {
            translate([0,0,0])
            difference() {
                rotate_extrude(convexity = 10, $fn=100)
                translate([(major_radius), 0, 0])
                
                difference () {
                    circle (r=minor_radius+wall_thickness, $fn=100);
                    translate ([-(minor_radius+wall_thickness),0])
                   square (2*(minor_radius+wall_thickness));
                    translate ([-2*(minor_radius+wall_thickness),-2*(minor_radius+wall_thickness)])
                    square (2*(minor_radius+wall_thickness));
                };   
                
               % rotate_extrude(convexity = 10, $fn=100)
                translate([(major_radius), 0, 0])
                difference () {
                    circle (r=minor_radius, $fn=100);
                    translate ([-(minor_radius),-0])
                    square (2*(minor_radius));
                    translate ([-2*minor_radius,-2*minor_radius])
                    square (2*(minor_radius));
                };
            }
        }
        // top-plane knife
       /* translate([0,0,minor_radius])
        cylinder(h=minor_radius*2,r=major_radius+minor_radius*2,center=true);
  
        // inner-torus cylinder knife
        translate([0,0,-(minor_radius/2)])
        cylinder(h=minor_radius*10,r=major_radius,center=true,$fn=100);  */
    }
    translate([0,0,-(minor_radius+(wall_thickness/2))])
    cylinder(h=wall_thickness,r=major_radius,center=true,$fn=100);
}
 
 
module water_cone() {
    cylinder (r1 = water_base_radius, r2 = water_top_radius, h = water_height, $fn=100);
}
         
module water_base() {
    union() {
                                  rotate_extrude(convexity = 10, $fn=100)
                    translate([(major_radius), 0, 0])
                    difference () {
                        circle (r=minor_radius, $fn=100);
                        translate ([-(minor_radius),-0])
                        square (2*(minor_radius));
                        translate ([-2*minor_radius,-2*(minor_radius)])
                        square (2*(minor_radius));
                    }; 
   
    translate([0,0,-(minor_radius)/2])
    cylinder(h=(minor_radius),r=major_radius,center=true,$fn=100);
    };
}

module water() {
                water_base();
                water_cone();
};
//color("blue")
//water();


module flask1() {
    flask_cone();
    flask_base();
}


if (USE_VERTICAL_KNIFE) {
    difference() {
        s = outer_base_radius*10;
        union(){
            flask1(); 
            water();
        };
        translate([0,-s/2,0])
        cube(s,center=true); 
    } 
} else {
    flask1();
    water();
}


module potInterface(ri,ro,rim_bead_radius = 10) {
    difference() {
        rotate_extrude(angle = 360, convexity = 10,$fn=100) 
        translate([ri, 0])
        circle(r = rim_bead_radius);
      // now cutaway a cylinder of radius rotate
        difference() {
            %cylinder(h=80,r1=ro+rim_bead_radius,r2=a*(ro+rim_bead_radius),center=true);
            %cylinder(h=100,r1=ri,r2=a*ri,center=true);
        }
    }
}
translate ([0,0,height-(rim_bead_radius/1)])
potInterface(rim_radius,outer_rim_radius, rim_bead_radius);
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

//Ivan
distance=0.0;  //change

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
     inner_base_radius;

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



//***********Lid Modules***************


// This is our main pot lid.
module concaveconicalLid(inner_rad){
    outer_rad = inner_rad+wall_thickness;
    inner_base_radius = radius(A,V_pot);
    
    union(){
        difference(){
            union () {
                difference(){
                    scale([1,1,lid_scale_factor])
                        sphere(inner_base_radius*conical_lid_scale_factor);
                    translate([0,0,-inner_base_radius*conical_lid_scale_factor])
                    cube((inner_base_radius*conical_lid_scale_factor)*2, center = true);
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
                lidInterface(inner_base_radius,inner_base_radius+wall_thickness,
                    rim_bead_radius);
            }
            scale([1,1,lid_scale_factor])
                sphere((inner_base_radius*conical_lid_scale_factor)-lid_wall_size);
        }
        
        // This is the handle
        difference(){
            union(){
                rotate([0,90,0])
                scale([lid_handle_scale_factor,1,1])
                translate([-(inner_base_radius*conical_lid_scale_factor)/2,0,0])
                lidhandleshell();
                translate([0,-(inner_base_radius*conical_lid_scale_factor)/1.8,0])
                rotate([25,0,0])
                cylinder(conical_end_height,lid_handle_thickness/2.1,(lid_handle_thickness/2)*conical_end_scale_factor);
               translate([0,(inner_base_radius*conical_lid_scale_factor)/1.8,0])
                rotate([-25,0,0])
                cylinder(conical_end_height,lid_handle_thickness/2.1,(lid_handle_thickness/2)*conical_end_scale_factor);
            }
            difference(){
                cylinder (h=conical_lid_height, r1=(outer_rad*conical_lid_scale_factor), r2 =(outer_rad));  
                scale([1,1,lid_scale_factor])
                sphere(inner_base_radius*conical_lid_scale_factor);
                scale([1,1,lid_scale_factor])
                sphere((inner_base_radius*conical_lid_scale_factor)-lid_wall_size);
                    translate([0,0,-inner_base_radius*conical_lid_scale_factor])
                    cube((inner_base_radius*conical_lid_scale_factor)*2, center = true);
            }
        }

    }
}
