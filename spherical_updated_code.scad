//i,j --> thetha,phi --> r --> x,y,z 
//we are converting from radians to degrees 

PI = 3.14159;
r = 10; //radius
n = 6; //number of waves 
f = 0.2; //amplitude 
g = 3.0; //becomes more square as it increases 
grid_size = 100; 
t = 0.2; //thickness

// We'll use the convention from here:
// https://en.wikipedia.org/wiki/Spherical_coordinate_system
// theta is the angle with the polar axis z
// phi is the rotation around the polar axis z
dtheta = (PI/2)/grid_size; //0 to 90 degrees
dphi = (2*PI)/grid_size; //0 to 180 degrees

function wavy_pot_inner_norm(theta,phi) = (1 + f*cos(n*phi*180/PI)* pow(sin(2*theta*180/PI), g));
function wavy_pot_outer(theta,phi) = 
    (r+t)*wavy_pot_inner_norm(theta,phi); 

function wavy_pot_inner(theta,phi) = 
    (r)*wavy_pot_inner_norm(theta,phi);

function x(r,theta,phi)= r*sin(theta*180/PI)*cos(phi*180/PI);

function y(r,theta,phi)= r*sin(theta*180/PI)*sin(phi*180/PI);

function z(r,theta)= r*cos(theta*180/PI);

prism_faces_1 = [[3,2,5],[4,0,1],[0,2,1],[2,3,1],[1,3,4],[3,5,4],[5,2,4],[2,0,4]];
prism_faces_2 = [[4,5,1],[2,0,3],[5,4,2],[2,3,5],[4,1,0],[0,2,4],[1,5,3],[3,0,1]];

function cartesian(theta,phi,rho) =
    [x(rho, theta, phi),
     y(rho, theta, phi),
     z(rho, theta)];

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