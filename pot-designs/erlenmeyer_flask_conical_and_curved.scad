aspect_ratio = 0.3;
major_radius = 20;
minor_radius = 2; //radius of base curvature
outer_base_radius = major_radius + minor_radius; //bottom radius of the erlenmeyer flask
height = (2*outer_base_radius)*aspect_ratio;
wall_thickness = outer_base_radius/20; //wall thickness
a = 0.5; // r/R 0 < a <1, r/R radius factor which is a ratio of rim radius to base radius
rim_radius = outer_base_radius*a;
delta_radius_outer = (1-a)*outer_base_radius;
inner_height = height-wall_thickness;
//delta_radius_inner = (inner_height/height)*(delta_radius_outer);
inner_base_radius = outer_base_radius-wall_thickness;//(outer_base_radius*(height-wall_thickness))/height;
inner_rim_radius = ((height*(inner_base_radius)-((height-wall_thickness)*(1-a)*outer_base_radius))/height)-wall_thickness;



//union () {
//    cylinder (h = height, r1 = outer_base_radius, r2 = outer_base_radius/2);
//    union () {
//    translate ([0,0,-minor_radius])
//    cylinder (h=minor_radius*2,r = major_radius);
//    
//    translate([0,0,0])
//    rotate_extrude(convexity = 10, $fn=100)
//    translate([major_radius, 0, 0])
//    circle(r = minor_radius, $fn=100);
//    
//                    };
// };

 //slicer
difference () {
    difference () {
    //pot outer shell
    //pot top end
    union () {
        cylinder (r1 = outer_base_radius, r2 = rim_radius, h = height, $fn=100);
            //curved base of pot
            difference () {
                rotate_extrude(convexity = 10, $fn=100)
                translate([major_radius, 0, 0])
                circle(r = minor_radius, $fn=100);
                rotate_extrude(convexity = 10, $fn=100)
//                translate([major_radius-minor_radius/major_radius, 0, 0])
//                circle(r = minor_radius, $fn=100);
//                cylinder (r = major_radius+minor_radius*2, h = height);
                translate ([0,0,-(minor_radius*2)])
                cylinder (r=major_radius, h = height*2);
                translate ([0,0,-(2*height+minor_radius/2)])
            cylinder (r=outer_base_radius, h=height*2);
                          }; 
            //base flatness and filler
            translate ([0,0,-(minor_radius/2)])
            cylinder (r = major_radius+minor_radius, h = (minor_radius/major_radius)); 
            translate ([0,0,-(minor_radius/2)])
            cylinder (r=major_radius, h=minor_radius/2);
//            translate ([0,0,-(minor_radius)/2])
//            cylinder (r = major_radius+minor_radius, h = (minor_radius/2)); //(((minor_radius+major_radius)*pow(3,1/2))/2)
                       
              };
              
              
              
      //pot inner shell
    //pot top end
    translate ([0,0,0])
    union () {
        union () {
            cylinder (r1 = inner_base_radius, r2 = inner_rim_radius, h = height, $fn=100);
            translate ([0,0,height])
            cylinder (r=inner_rim_radius,h = height);
         };
            //curved base of pot
            difference () {
                rotate_extrude(convexity = 10, $fn=100)
                translate([major_radius-wall_thickness, 0, 0])
                circle(r = minor_radius, $fn=100);
                rotate_extrude(convexity = 10, $fn=100)
//                translate([major_radius-minor_radius/major_radius, 0, 0])
//                circle(r = minor_radius, $fn=100);
//                cylinder (r = major_radius+minor_radius*2, h = height);
                translate ([0,0,-(minor_radius*2)])
                cylinder (r=major_radius-wall_thickness, h = height*2);
                translate ([0,0,-(2*height+minor_radius/2)])
            cylinder (r=inner_base_radius, h=height*2);
                          }; 
            //base flatness and filler
            translate ([0,0,-(minor_radius/2)])
            cylinder (r = (major_radius-wall_thickness)+minor_radius, h = (minor_radius/(major_radius-wall_thickness))); 
            translate ([0,0,-(minor_radius/2)])
            cylinder (r=major_radius-wall_thickness, h=minor_radius/2);
//            translate ([0,0,-(minor_radius)/2])
//            cylinder (r = major_radius+minor_radius, h = (minor_radius/2)); //(((minor_radius+major_radius)*pow(3,1/2))/2)
                       
              };
             };
              
    translate ([-50,0,-10])
    cube (major_radius*5);
 };
//cylinder (r = major_radius+minor_radius, h = height);