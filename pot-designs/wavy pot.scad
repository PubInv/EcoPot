//    wavy_pot.scad - model of possibly heat-efficient pot
//    Copyright (C) 2026  Robert L. Read, Ginaluca Skirde, Jahnavi Pelacha
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Affero General Public License as
//    published by the Free Software Foundation, either version 3 of the
//    License, or (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Affero General Public License for more details.
//
//    You should have received a copy of the GNU Affero General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

// We want this to be a little bigger than 100 ml.
// Integrating the volume of this is a little tricky,
// but we can model it as hemisphere. However,
// we want this to fit with our previous lids,
// so we will have to deal with that.

RADIUS_OF_100_ML_HS = 37.6;
VOLUME_BUFFER_RATIO = 1.2;

L=RADIUS_OF_100_ML_HS*VOLUME_BUFFER_RATIO; //radius 
A=10; //amplitude
N=8; //number of waves
t=1; //thickness
grid_size=200; //divisons of hemisphere 

//desmos equation

function z1_outer(x,y)=sqrt(max(0,L*L-x*x-y*y)); //height of cylinder 
function z1_inner(x,y)=sqrt(max(0,(L-t)*(L-t)-x*x-y*y)); //height of cylinder for t thickness 
function theta(x,y)=atan2(y,x);
function phi_outer(x,y)=atan(sqrt(x*x+y*y)/(z1_outer(x,y)+0.0001));
function phi_inner(x,y)=atan(sqrt(x*x+y*y)/(z1_inner(x,y)+0.0001));
function F_full_outer(x,y)=(L+A*sin(N*theta(x,y))*sin(z1_outer(x,y)*180/L))*cos(phi_outer(x,y));
function F_full_inner(x,y)=((L-t)+A*sin(N*theta(x,y))*sin(z1_inner(x,y)*180/(L-t)))*cos(phi_inner(x,y));

//divides each cell into dx and dy 
dx=(2*L)/grid_size; //Divides the square area into small tiles.
dy=(2*L)/grid_size;

//first triangle in the square grid cell + second triangle completing the cell
//Each grid square: split into two prisms
prism_faces_1=[[3,2,5],[4,0,1],[0,2,1],[2,3,1],[1,3,4],[3,5,4],[5,2,4],[2,0,4]];
prism_faces_2=[[4,5,1],[2,0,3],[5,4,2],[2,3,5],[4,1,0],[0,2,4],[1,5,3],[3,0,1]];

//loops over every grid
//combines all prisms in the grid to get a full wavy hemisphere shell with thickness
module wavy_pot() {
    union(){
        for(i=[0:grid_size-1]){
            for(j=[0:grid_size-1]){
                let(
                    x=-L+i*dx,
                    y=-L+j*dy,
                    x2=x+dx,
                    y2=y+dy //Defines the four corners of one grid square.
                )
                if(sqrt(x*x+y*y)<=L){ //cuts away the square corners

                    polyhedron(
                        points=[ 
                            [x,y,F_full_inner(x,y)],
                            [x2,y,F_full_inner(x2,y)],
                            [x,y,F_full_outer(x,y)],
                            [x2,y,F_full_outer(x2,y)],
                            [x2,y2,F_full_inner(x2,y2)],
                            [x2,y2,F_full_outer(x2,y2)]
                        ],
                        faces=prism_faces_1
                    ); //Creates half of the square cell with thickness

                    polyhedron(
                        points=[
                            [x,y,F_full_inner(x,y)],
                            [x,y,F_full_outer(x,y)],
                            [x,y2,F_full_inner(x,y2)],
                            [x2,y2,F_full_inner(x2,y2)],
                            [x,y2,F_full_outer(x,y2)],
                            [x2,y2,F_full_outer(x2,y2)]
                        ],
                        faces=prism_faces_2 //Completes the square by filling the other triangle.
                    );
                }
            }
        }
    }
}
module smoothed_wavy() {
    minkowski() {
        wavy_pot();
        sphere(1);
    }
}
wavy_pot();