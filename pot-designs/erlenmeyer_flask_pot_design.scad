//added 25th January, 2026

//R = base radius
//r = top radius
//a = radius factor = r/R (0 < a <1)
//A = aspect ratio = height / diameter = h/2R
// V = 1/3*pi*h(R^2 + r^2 + Rr)
//but h = Ad = A*2R, r = aR
//V = 1/3*pi*2AR(R^2 +(aR)^2 + aR^2)
//R = (3V/(2*pi*A(1 + a + a^2))^1/3
//h = A*2R
//V_pot = V_water * excess_lip_scale_factor
//V_ml = 100
//V_water = V_ml * 1000 (mm^3)

aspect_ratio = 0.5;
major_radius = 20;
minor_radius = 2; //radius of base curvature
base_radius = major_radius + minor_radius; //bottom radius of the erlenmeyer flask
height = (2*base_radius)*aspect_ratio;
wall_thickness = base_radius/20; //wall thickness

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
 
 //inner shell of pot
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