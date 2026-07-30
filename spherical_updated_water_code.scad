PI = 3.14159;
// r = 10; //radius
r = 39.3275; // This is the radius of the actual pot
n = 6; //number of waves 
f = 0.2; //amplitude 
g = 3.0; //becomes more square as it increases 
grid_size = 50; 
t = 0.2; //thickness

dtheta = (PI/2)/grid_size; //0 to 90 degrees

dphi = (2*PI)/grid_size; //0 to 180 degrees

function wavy_pot_inner_norm(theta,phi) = (1 + f*cos(n*phi*180/PI)* pow(sin(2*theta*180/PI), g));
function wavy_pot_outer(theta,phi) = 
    (r+t)*wavy_pot_inner_norm(theta,phi); 

function wavy_pot_inner(theta,phi) = 
    (r)*wavy_pot_inner_norm(theta,phi);

function x(r,theta,phi)= r*sin(theta*180/PI)*cos(phi*180/PI);

function y(r,theta,phi)= r*sin(theta*180/PI)*sin(phi*180/PI);

function z(r,theta)= 1*r*cos(theta*180/PI);

prism_faces_1 = [[3,2,5],[4,0,1],[0,2,1],[2,3,1],[1,3,4],[3,5,4],[5,2,4],[2,0,4]];
prism_faces_2 = [[4,5,1],[2,0,3],[5,4,2],[2,3,5],[4,1,0],[0,2,4],[1,5,3],[3,0,1]];

function cartesian(theta,phi,rho) =
    [x(rho, theta, phi),
     y(rho, theta, phi),
     z(rho, theta)];

module wavy_pot()
{
    union() {
        for(i = [0 : grid_size - 1]) {
            for(j = [0 : grid_size - 1]) {

                theta0 = i*dtheta;
                phi0 = j*dphi;
                theta1 = (i + 1)*dtheta;
                phi1 = (j + 1)*dphi;

                //outer_radius
                ro00 = wavy_pot_outer(theta0, phi0);
                ro10 = wavy_pot_outer(theta1, phi0);
                ro11 = wavy_pot_outer(theta1, phi1);
                ro01 = wavy_pot_outer(theta0, phi1);

                //inner_radius 
                ri00 = wavy_pot_inner(theta0, phi0);
                ri10 = wavy_pot_inner(theta1, phi0);
                ri11 = wavy_pot_inner(theta1, phi1);
                ri01 = wavy_pot_inner(theta0, phi1);

                i00 = cartesian(theta0,phi0,wavy_pot_inner(theta0, phi0));
                i01 = cartesian(theta0,phi1,wavy_pot_inner(theta0, phi1)); 
                i10 = cartesian(theta1,phi0,wavy_pot_inner(theta1, phi0));
                i11 = cartesian(theta1,phi1,wavy_pot_inner(theta1, phi1)); 
  
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
                );

                polyhedron(
                    points=[
                    i00,
                    o00,
                    i01,
                    i11,
                    o01,
                    o11],
                    faces=prism_faces_2
                );
            }
        }
    }
}

//water component 

function wavy_pot_inner_norm_water(theta,phi) = (1 + f*cos(n*phi*180/PI)* pow(sin(2*theta*180/PI), g));

function wavy_pot_outer_water(theta,phi) = 
    (r+t)*wavy_pot_inner_norm_water(theta,phi); 

function wavy_pot_inner_water(theta,phi) = 
    (r)*wavy_pot_inner_norm_water(theta,phi);

function x_water(r,theta,phi)= r*sin(theta*180/PI)*cos(phi*180/PI);

function y_water(r,theta,phi)= r*sin(theta*180/PI)*sin(phi*180/PI);

water_height = 1.0; 

function z_water(r,theta)= water_height*r*cos(theta*180/PI);

function cartesian_water(theta,phi,rho) =
    [x_water(rho, theta, phi),
     y_water(rho, theta, phi),
     z_water(rho, theta)];
     
function tetrahedron_from_origin_volume(A,B,C) = 
 let(
    a = [A[0] - B[0],A[1] - B[1],A[2] - B[2]],
    b = [B[0] - C[0],B[1] - C[1],B[2] - C[2]],
    c = [C[0] - A[0],C[1] - A[1],C[2] - A[2]],
    
    side_a = sqrt(a[0]*a[0] +a[1]*a[1] +a[2]*a[2]),
    side_b = sqrt(b[0]*b[0] +b[1]*b[1] + b[2]*b[2]),
    side_c = sqrt(c[0]*c[0] + c[1]*c[1] + c[2]*c[2]),
    s = (side_a + side_b + side_c)/2,
    base_area = sqrt(s*(s-side_a)*(s-side_b)*(s-side_c)),
    //b x c
    cross = [b[1]*c[2] - b[2]*c[1],b[2]*c[0] - b[0]*c[2],b[0]*c[1] - b[1]*c[0]],
    //a dot (b x c)
    dot = A[0]*cross[0] +A[1]*cross[1] +A[2]*cross[2],
    //|b x c|
    cross_length = sqrt(cross[0]*cross[0] + cross[1]*cross[1] +cross[2]*cross[2]),
    //height
    h = abs(dot)/cross_length, 
    x = (cross_length == 0)? 
        echo("⚠️ WARNING: Cross Length 0!",A,B,C) 10 : 11)
    //now, volume = 1/3*Base_Area*Height
    (cross_length == 0) ? 0.0 : base_area*h*1/3 ;
   
function sum(list, index = 0) = 
    index >= len(list) ? 0 : list[index] + sum(list, index + 1);

module wavy_pot_water()
{
    list = [
        for(i = [0 : grid_size - 1]) 
            for(j = [0 : grid_size - 1]) 
                let(
                theta0 = i*dtheta, // This is "around the z axis"?
                phi0 = j*dphi, // angle with the z-axis?
                theta1 = (i + 1)*dtheta,
                phi1 = (j + 1)*dphi,

                //outer_radius
                ro00 = wavy_pot_outer_water(theta0, phi0),
                ro10 = wavy_pot_outer_water(theta1, phi0),
                ro11 = wavy_pot_outer_water(theta1, phi1),
                ro01 = wavy_pot_outer_water(theta0, phi1),

                //inner_radius 
                ri00 = wavy_pot_inner_water(theta0, phi0),
                ri10 = wavy_pot_inner_water(theta1, phi0),
                ri11 = wavy_pot_inner_water(theta1, phi1),
                ri01 = wavy_pot_inner_water(theta0, phi1),

                i00x = cartesian_water(theta0,phi0,wavy_pot_inner_water(theta0, phi0)),
                i01x = cartesian_water(theta0,phi1,wavy_pot_inner_water(theta0, phi1)), 
                i10x = cartesian_water(theta1,phi0,wavy_pot_inner_water(theta1, phi0)),
                i11x = cartesian_water(theta1,phi1,wavy_pot_inner_water(theta1, phi1)), 
           
//o00 = cartesian_water(theta0,phi0,wavy_pot_outer_water(theta0, phi0));
//o01 = cartesian_water(theta0,phi1,wavy_pot_outer_water(theta0, phi1)); 
// o10 = cartesian_water(theta1,phi0,wavy_pot_outer_water(theta1, phi0));
// o11 = cartesian_water(theta1,phi1,wavy_pot_outer_water(theta1, phi1));     
                o00 = i00x,
                o01 = i01x, 
                o10 = i10x,
                o11 = i11x, 
             
                            
                i00 = [0,0,0],
                i01 = [0,0,0], 
                i10 = [0,0,0],
                i11 = [0,0,0],  
               
//we find the the length of each side, we find x,y,z for each side, and then calculate the length. we find the base area, then we use the formula for 1/3*base_area*the height; h = a.(bxc)/|b x c|

                A = o00,
                B = o10,
                C = o11, 
                volumefaces1x = tetrahedron_from_origin_volume(A,B,C),
                    points1=[
                    i00,
                    i10,
                    o00,
                    o10,
                    i11,
                    o11],
                A1 = o00,
                B1 = o01,
                C1 = o11,
                
                volumefaces2x = tetrahedron_from_origin_volume(A1,B1,C1),

                 points2=[
                    i00,
                    o00,
                    i01,
                    i11,
                    o01,
                    o11]
             ) 
       echo("AAAAA")
       echo(volumefaces1x)
       echo(volumefaces2x)
          [points1,points2]
          ]
          ;
    echo("list = ");
    echo(list);
    union() {
        for (p = list) {
            echo(p[0]);
             polyhedron(
                points=p[0],
                faces=prism_faces_1
                );
              polyhedron(
                points=p[1],
                faces=prism_faces_2
               );
            echo(p[1]);
        }
    };
    
    echo(list);
   volumes = [for (p = list) 
        let (A = p[0][2],
            B = p[0][3],
            C = p[0][5],
            volumefaces1x = tetrahedron_from_origin_volume(A,B,C),
            A1 = p[1][1],
            B1 = p[1][4],
            C1 = p[1][5],
            volumefaces2x = tetrahedron_from_origin_volume(A1,B1,C1))
            volumefaces1x + volumefaces2x
         ];
    echo("volumes");
    echo(volumes);
    echo("total volume (ml):");
    echo(sum(volumes) / 1000);
}
module MultiScaleWavyPotWater() {
//for(i = [0:100]) {
//
//    s = 1-i*0.01;
//            scale(s)
//            wavy_pot_water();
//            }   
}
//difference() {
//    wavy_pot_water();
//    cylinder(h= 2, r = 100, center=true);
//}

// wavy_pot_water();

difference() {
    // h = 20;
    // Compute a height h for the "knife" that represents
    // a 30ml volume.
    // V = h * pi * r^2.
    // V / (pi * r^2) = h
    V = 30; // ml....
    // V must be converted to cubic millimters.
    V_mm = 30 * 1000;
    h = V_mm / ( PI * r^2);
    echo("h is computed as:");
    echo(h);
    wavy_pot_water();
    translate([0,0,h/2-0.01])
    #cylinder(h= h, r = 100, center=true);
}
