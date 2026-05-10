//i,j --> thetha,phi --> r --> x,y,z 
//we are converting from radians to degrees 

PI = 3.14159;
r = 10; //radius
n = 4; //number of waves 
f = 0.4; //amplitude 
g = 1.5; //becomes more square as it increases 
grid_size = 300; 
t = 0.2; //thickness

dtheta = (PI/2)/grid_size; //0 to 90 degrees
dphi = (2*PI)/grid_size; //0 to 180 degrees

function wavy_pot_outer(theta,phi) = 
    r*(1 + f*cos(n*theta*180/PI)* pow(abs(sin(2*phi*180/PI)), g)); 

function wavy_pot_inner(theta,phi) = 
    (r - t)*(1 + f*cos(n*theta*180/ PI)*pow(abs(sin(2*phi*180/PI)), g));

function x(r, theta, phi)= r*sin(theta*180/PI)*cos(phi*180/PI);

function y(r,theta,phi)= r*sin(theta*180/PI)*sin(phi*180/PI);

function z(r,theta)= r*cos(theta*180/PI);

prism_faces_1 = [[3,2,5],[4,0,1],[0,2,1],[2,3,1],[1,3,4],[3,5,4],[5,2,4],[2,0,4]];
prism_faces_2 = [[4,5,1],[2,0,3],[5,4,2],[2,3,5],[4,1,0],[0,2,4],[1,5,3],[3,0,1]];

union() {
    for(i = [0 : grid_size - 1]) {
        for(j = [0 : grid_size - 1]) {

            theta0 = i*dtheta;
            phi0 = j*dphi;
            theta1 = (i + 1)*dtheta;
            phi1 = (j + 1)*dphi;

            //outer_radius
            r00 = wavy_pot_outer(theta0, phi0);
            r10 = wavy_pot_outer(theta1, phi0);
            r11 = wavy_pot_outer(theta1, phi1);

            //inner_radius 
            ri00 = wavy_pot_inner(theta0, phi0);
            ri10 = wavy_pot_inner(theta1, phi0);
            ri11 = wavy_pot_inner(theta1, phi1);

            point = [
                [x(r00, theta0, phi0), y(r00, theta0, phi0), z(r00, theta0)],
                [x(r10, theta1, phi0), y(r10, theta1, phi0), z(r10, theta1)],
                [x(r11, theta1, phi1), y(r11, theta1, phi1), z(r11, theta1)],
                [x(ri00, theta0, phi0), y(ri00, theta0, phi0), z(ri00, theta0)],
                [x(ri10, theta1, phi0), y(ri10, theta1, phi0), z(ri10, theta1)],
                [x(ri11, theta1, phi1), y(ri11, theta1, phi1), z(ri11, theta1)]
            ];

            polyhedron(points = point, faces = prism_faces_1);
            polyhedron(points = point, faces = prism_faces_2);
        }
    }
}