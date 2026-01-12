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
cylinder (h=56, r1 = 40, r2 = 15);
translate([0,47,0])
sphere(5);
};

};

translate ([-75,0,-50])
cube (150);
};