L=9.07; // radius 
A=3; // amplitude
N=5; // number of waves
t=0.2; // thickness
grid_size=300; // divisions of hemisphere 

function z1_outer(x,y)=sqrt(max(0,L*L-x*x-y*y)); 
function z1_inner(x,y)=sqrt(max(0,(L-t)*(L-t)-x*x-y*y)); 
function theta(x,y)=atan2(y,x);
function phi_outer(x,y)=atan(sqrt(x*x+y*y)/(z1_outer(x,y)+0.0001));
function phi_inner(x,y)=atan(sqrt(x*x+y*y)/(z1_inner(x,y)+0.0001));

function F_full_outer(x,y)=(L+A*sin(N*theta(x,y))*sin(z1_outer(x,y)*180/L))*cos(phi_outer(x,y));
function F_full_inner(x,y)=((L-t)+A*sin(N*theta(x,y))*sin(z1_inner(x,y)*180/(L-t)))*cos(phi_inner(x,y));

function thickness_at(x,y) = F_full_outer(x,y) - F_full_inner(x,y);

// Recursive function to sum the volume list
function sum_list(list, index=0, total=0) = 
    index >= len(list) ? total : sum_list(list, index + 1, total + list[index]);

// Grid increments
dx=(2*L)/grid_size; 
dy=(2*L)/grid_size;

prism_faces_1=[[3,2,5],[4,0,1],[0,2,1],[2,3,1],[1,3,4],[3,5,4],[5,2,4],[2,0,4]];
prism_faces_2=[[4,5,1],[2,0,3],[5,4,2],[2,3,5],[4,1,0],[0,2,4],[1,5,3],[3,0,1]];

let(
    cell_volumes = [for(i=[0:grid_size-1], j=[0:grid_size-1])
        let(
            x = -L + i*dx, 
            y = -L + j*dy, 
            x2 = x + dx, 
            y2 = y + dy
        )
        (sqrt(x*x + y*y) <= L) ? 
            let(
                //volume of triangle 1 
                v1 = 0.5 * dx * dy * ((thickness_at(x,y) + thickness_at(x2,y) + thickness_at(x2,y2))/3),
                //triangle two volume
                v2 = 0.5 * dx * dy * ((thickness_at(x,y) + thickness_at(x,y2) + thickness_at(x2,y2))/3)
            )
            (v1 + v2) : 0
    ],
    // sum
    total_volume = sum_list(cell_volumes)
) {

    echo();
    echo(str(total_volume));
    echo();
    union(){
        for(i=[0:grid_size-1]){
            for(j=[0:grid_size-1]){
                let(
                    x=-L+i*dx,
                    y=-L+j*dy,
                    x2=x+dx,
                    y2=y+dy 
                )
                if(sqrt(x*x+y*y)<=L){ 
                    // PRISM 1
                    polyhedron(
                        points=[ 
                            [x,y,F_full_inner(x,y)], [x2,y,F_full_inner(x2,y)],
                            [x,y,F_full_outer(x,y)], [x2,y,F_full_outer(x2,y)],
                            [x2,y2,F_full_inner(x2,y2)], [x2,y2,F_full_outer(x2,y2)]
                        ],
                        faces=prism_faces_1
                    );
                    // PRISM 2
                    polyhedron(
                        points=[
                            [x,y,F_full_inner(x,y)], [x,y,F_full_outer(x,y)],
                            [x,y2,F_full_inner(x,y2)], [x2,y2,F_full_inner(x2,y2)],
                            [x,y2,F_full_outer(x,y2)], [x2,y2,F_full_outer(x2,y2)]
                        ],
                        faces=prism_faces_2 
                    );
                }
            }
        }
    }
}