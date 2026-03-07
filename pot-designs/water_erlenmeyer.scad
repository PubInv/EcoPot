//updated 10th February, 2026


PI = 3.141592;


//V_pot = V_water * excess_lip_scale_factor
//V_ml = 100
//V_water = V_ml * 1000 (mm^3)

// Volume of water in mL
V_ml = 100;
V_water = V_ml * 1000; //cubic millimeters

// Shape ratios

A_pot = 0.9; //Ratio of pot height to the base radius of pot
// Note: C of less than 0.2 fails in this construction...
C = 0.4; //curvature factor  = major_radius/minor_radius. PS: 1.05 was the original setting.

echo (C);
A = A_pot - (0.5/(C+1));   // A = h / (2*R) this is defined only for the frustrum
echo("A");
echo(A);
// ratio of baseRadius to minor_radius must be 
// specified.
// R = 0.25;  // this is ratio of minor_radius to base_radius
excessLipScale = 1.1; 

// ratio of rim radius to base radius
a = 0.6; // r/R 0 < a <1, r/R radius factor which is a ratio of rim radius to base radius  

// base radius R from formula:
// V = (1/3)*PI*2*A*R*(R^2 + (aR)^2 + R*aR) = (2/3)*PI*A*R^3*(1 + a + a^2)
// not quite complete.....
//baseRadius = pow( (3*V_water)/(2*PI*A*(1 + a + pow(a, 2))), 1/3 );
// TODO: Consider volume of torus (divided by 4),
// volume of cylinder of height = minor_radius,
// radius = major_radius - minor_radius
// That volume formula must use R.
// minor_radius must be computed from the Volume and R and A.

// Top radius
//topRadius = a * baseRadius;

// Height
//potHeight = A * 2 * baseRadius;

// Pot volume with lip
V_pot = V_water * excessLipScale;



aspect_ratio = 0.5;


// TODO: Remove the limitation that the major_radius 
// has to be greater than or equal to the minor_radius

outer_base_radius = pow(((V_pot)/(PI*((((2*A)/3)*(pow(a,2)+a+1))+((pow((C-1),2)+(2*PI*C))/(pow((C+1),3)))))),1/3); //bottom radius of the erlenmeyer flask
minor_radius = outer_base_radius/(C+1); //radius of base curvature
major_radius = C * minor_radius;

height = (2*outer_base_radius)*A;
wall_thickness = outer_base_radius/20; //wall thickness


//outer_base_radius = major_radius + minor_radius; 


rim_radius = outer_base_radius*a;
delta_radius_outer = (1-a)*outer_base_radius;
inner_height = height-wall_thickness;
//delta_radius_inner = (inner_height/height)*(delta_radius_outer);
inner_base_radius = outer_base_radius-wall_thickness;//(outer_base_radius*(height-wall_thickness))/height;

inner_rim_radius = inner_base_radius - (outer_base_radius*(1-a));


USE_VERTICAL_KNIFE = true;

module water_cone() {

            cylinder (r1 = inner_base_radius, r2 = inner_rim_radius, h = height, $fn=100);
};
         
module water_base() {
    union() {
                                  rotate_extrude(convexity = 10, $fn=30)
                    translate([(major_radius), 0, 0])
                    difference () {
                        circle (r=minor_radius-wall_thickness, $fn=30);
                        translate ([-(minor_radius-wall_thickness),-0])
                        square (2*(minor_radius-wall_thickness));
                        translate ([-2*minor_radius,-2*(minor_radius-wall_thickness)])
                        square (2*(minor_radius-wall_thickness));
                    }; 
   
    translate([0,0,-(minor_radius-wall_thickness)/2])
    cylinder(h=(minor_radius-wall_thickness),r=major_radius,center=true);
    };
};

module water() {
                water_base();
                water_cone();
};