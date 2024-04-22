// Copyright Cledden Obeng-Poku Kwanin and Robert L. Read, 2024
// Released under CERN Strong-reciprocal Open Hardware License

// This is an attempt to make a new parametrized experimental apparatus
// for teting our ferrofluid check valve. It will be similar to the system
// that Veronica design in SolidWorks, but will use the improved, 360 degree design


pot_height = 10;
wall_thickness =1;
outer_rad =5;
inner_rad = 4;
base_scale_factor = 2;
height_scale_factor = 0.5;


// ptype = "flatbottom";
ptype = "roundbottom";



module renderPotType(ptype) {
if (ptype == "flatbottom") {
    translate([0,20,0])
    union () {
        scale ([base_scale_factor,base_scale_factor,height_scale_factor])
        sphere (r = inner_rad);

        cylinder (h=pot_height+2,r1 =2*inner_rad, r2 =2*inner_rad);
    }
} else if (ptype == "roundbottom") {
    difference() {    
        union () {
            scale ([base_scale_factor,base_scale_factor,height_scale_factor])
            color ("red")
            sphere (outer_rad);
            color("blue")
            cylinder (h=pot_height,r=2*outer_rad,r2=2*outer_rad);
        }
        union () {
            scale ([base_scale_factor,base_scale_factor,height_scale_factor])
            sphere (r = inner_rad);
            cylinder (h=(pot_height*2),r =2*inner_rad, r2= 2*inner_rad);
        }
    }
} 
}

renderPotType("roundbottom");
renderPotType("flatbottom");

//difference () {
//cylinder (9,4,4);
//translate([0,0,1])cylinder (10,3,3);
//}
//difference () {
//translate ([0,10,4])
//sphere(4);
//translate ([0,10,6])
//sphere(3);
//}
//difference () {
//translate ([0,10,4])
//cylinder (5,4,4);
//translate ([0,10,5])
//cylinder (5,3,3);
//    
//}