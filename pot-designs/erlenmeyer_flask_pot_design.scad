//added 25th January, 2026


PI = 3.141592;

//R = base radius
//r = top radius
//a = radius factor = r/R (0 < a <1)
//A = aspect ratio = height / diameter = h/2R
// V = 1/3*PI*h(R^2 + r^2 + Rr)
//but h = Ad = A*2R, r = aR
//V = 1/3*PI*2AR(R^2 +(aR)^2 + aR^2)
//R = (3V/(2*PI*A(1 + a + a^2))^1/3
//h = A*2R
//V_pot = V_water * excess_lip_scale_factor
//V_ml = 100
//V_water = V_ml * 1000 (mm^3)

// Volume of water in mL
V_ml = 100;
V_water = V_ml * 1000;  

// Shape ratios


A = 1.5;       // A = h / (2*R)
// ratio of baseRadius to minor_radius must be 
// specified.
// R = 0.25;  // this is ratio of minor_radius to base_radius
excessLipScale = 1.1; 

// ratio of rim radius to base radius
a = 0.6; // r/R 0 < a <1, r/R radius factor which is a ratio of rim radius to base radius  

// base radius R from formula:
// V = (1/3)*PI*2*A*R*(R^2 + (aR)^2 + R*aR) = (2/3)*PI*A*R^3*(1 + a + a^2)
// not quite complete.....
baseRadius = pow( (3*V_water)/(2*PI*A*(1 + a + pow(a, 2))), 1/3 );
// TODO: Consider volume of torus (divided by 4),
// volume of cylinder of height = minor_radius,
// radius = major_radius - minor_radius
// That volume formul must use R.
// minor_radius must be computed from the Volume and R and A.

// Top radius
topRadius = a * baseRadius;

// Height
potHeight = A * 2 * baseRadius;

// Pot volume with lip
V_pot = V_water * excessLipScale;



aspect_ratio = 0.5;


// TODO: Remove the limitation that the major_radius 
// has to be greater than or equal to the minor_radius
C = 1.05; //curvature factor  = major_radius/minor_radius. PS: 1.05 was the original setting.
echo (C);
minor_radius = 20; //radius of base curvature
major_radius = C * minor_radius;
base_radius = major_radius + minor_radius; //bottom radius of the erlenmeyer flask
height = (2*base_radius)*aspect_ratio;
wall_thickness = base_radius/20; //wall thickness


outer_base_radius = major_radius + minor_radius; 


rim_radius = outer_base_radius*a;
delta_radius_outer = (1-a)*outer_base_radius;
inner_height = height-wall_thickness;
//delta_radius_inner = (inner_height/height)*(delta_radius_outer);
inner_base_radius = outer_base_radius-wall_thickness;//(outer_base_radius*(height-wall_thickness))/height;
inner_rim_radius = ((height*(inner_base_radius)-((height-wall_thickness)*(1-a)*outer_base_radius))/height)-wall_thickness;

USE_VERTICAL_KNIFE = true;


module flask0 () {
//slicer
difference () {
//pot code
difference () {
//outer shell of pot
union () {
    cylinder (h = height, r1 = base_radius, r2 = base_radius/2);
    union () {
    translate ([0,0,-minor_radius])
    cylinder (h=minor_radius*2,r = major_radius);
    
    translate([0,0,0])
    rotate_extrude(convexity = 10, $fn=100)
    translate([major_radius, 0, 0])
    circle(r = minor_radius, $fn=100);
    
                    };
 };
 

 translate ([0,0,wall_thickness/2])
union () {
    cylinder (h = height, r1 = (base_radius-wall_thickness), r2 = ((base_radius-wall_thickness)/2));
   union () {
    translate ([0,0,-(minor_radius)])
    cylinder (h=minor_radius*2,r = (major_radius-wall_thickness));
    
    translate([0,0,0])
    rotate_extrude(convexity = 10, $fn=100)
    translate([(major_radius-wall_thickness), 0, 0])
    circle(r = (minor_radius), $fn=100);
    
                    };
 };
 };
 translate ([-50,0,-10])
 cube (200);
 };
}


// flask0();

module flask_cone() {
    difference() {
        cylinder (r1 = outer_base_radius, r2 = rim_radius, h = height, $fn=100);
// inner subtracted part
        union () {
            cylinder (r1 = inner_base_radius, r2 = inner_rim_radius, h = height, $fn=100);
            translate ([0,0,height])
            cylinder (r=inner_rim_radius,h = height);
         };
    }
}

// TODO: don't extrude circle, but extrude a 1/4th of a circle shape
// Status: completed

module flask_base() {

    difference () {
        union() {
            translate([0,0,0])
            difference() {
                rotate_extrude(convexity = 10, $fn=30)
                translate([(major_radius), 0, 0])
                // here cut away top and inside 
                // also cut away inside 
            difference () {
                circle (r=minor_radius, $fn=30);
                translate ([-minor_radius,-0])
                square (2*minor_radius);
                translate ([-2*minor_radius,-2*minor_radius])
                square (2*minor_radius);
            };
//                circle(r = (minor_radius), $fn=30);
//        
                rotate_extrude(convexity = 10, $fn=30)
                translate([(major_radius), 0, 0])
            difference () {
                circle (r=minor_radius-wall_thickness, $fn=30);
                translate ([-(minor_radius-wall_thickness),-0])
                square (2*(minor_radius-wall_thickness));
                translate ([-2*minor_radius,-2*(minor_radius-wall_thickness)])
                square (2*(minor_radius-wall_thickness));
            };
//                circle(r = (minor_radius-wall_thickness), $fn=30);
            }
        }
        // top-plane knife
        translate([0,0,minor_radius])
        cylinder(h=minor_radius*2,r=major_radius*2,center=true);
  
        // inner-torus cylinder knife
        translate([0,0,-(minor_radius-wall_thickness/2)])
        cylinder(h=minor_radius*10,r=major_radius,center=true);  
    }
    translate([0,0,-(minor_radius-wall_thickness/2)])
    cylinder(h=wall_thickness,r=major_radius,center=true);
}



module flask1() {
    flask_cone();
    flask_base();
}

if (USE_VERTICAL_KNIFE) {
    difference() {
        s = base_radius*4;
        flask1(); 
        translate([0,-s/2,0])
       cube(s,center=true); 
    } 
} else {
    flask1();
}

/*

//the following calculations is to define the pot based on its aspect ratio (height/radius) and volume. It is currently incomplete and incorrect
V = 100;
function radius(A,V) = pow(V / (PI *(A - 1/3)),1/3);
function height(A,V) = A * radius(A,V);
wall_thickness = 5;
//inner_radius = radius (A,V) - wall_thickness;

//module erlenmeyer_flask (radius,) {
difference () {  //this difference operation is to cut out the pot. 

//the code from lines 12-30 makes the current profile.
difference () {

//outer shell of pot
translate ([0,-50,0])
minkowski () {
cylinder (h=50, r1 = 50, r2 = 25);
translate([0,50,0])
sphere(5);
};

//inner shell of pot
translate ([0,-40,wall_thickness])
minkowski () {
cylinder (h=45, r1 = 40, r2 = 20);
translate([0,47,0])
sphere(5);
};

};

translate ([-75,0,-50])
cube (150);
};

*/