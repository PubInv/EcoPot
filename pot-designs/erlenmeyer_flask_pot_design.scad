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

inner_base_radius = pow(((V_pot)/(PI*(((2*A*(1+a+pow(a,2)))/3)+((pow(C,2)*(1+(0.5*PI)))/(pow(C+1,3)))))),1/3);
//pow(((V_pot)/(PI*((((2*A)/3)*(pow(a,2)+a+1))+((pow((C-1),2)+(2*PI*C))/(pow((C+1),3)))))),1/3); //widest radius of the erlenmeyer flask
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
water_top_radius = pow((pow(inner_base_radius,3))-((3*(V_cone/E)*(inner_base_radius-rim_radius))/(PI*height)),1/3);
water_height = (a==1)? (height/E):((height*(inner_base_radius-water_top_radius))/(inner_base_radius-rim_radius));
V_water_base = V_base;
V_water_cone = PI*water_height*(1/3)*(pow(inner_base_radius,2) + (inner_base_radius * water_top_radius)+(pow(water_top_radius,2)));
V_water_model = V_water_base + V_water_cone;
V_pot_model = V_base + V_cone;
    echo("V_water_model",V_water_model,"V_pot_model", V_cone+V_base,"V_base",V_base,"V_pot",V_pot,"Difference",V_pot-V_pot_model,"inner_base_radius", inner_base_radius,"water_base_radius",water_base_radius,"water_top_radius",water_top_radius,"rim_radius",rim_radius,"water_height",water_height,"height",height,"A_pot",(height+minor_radius)/(2*inner_base_radius));

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
color("blue")
water();


module flask1() {
    flask_cone();
    flask_base();
}

//water();
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



