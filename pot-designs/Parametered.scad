pot_height = 10;
wall_thickness =1;
outer_rad =5;
inner_rad = 4;
base_scale_factor = 2;
height_scale_factor = 0.5;
union () {
scale ([base_scale_factor,base_scale_factor,height_scale_factor])
  color ("red")
  sphere (outer_rad);
    color("blue")
  cylinder (h=pot_height,r=2*outer_rad,2*outer_rad);
}
translate([0,20,0])
union () {
scale ([base_scale_factor,base_scale_factor,height_scale_factor])
  sphere (r = inner_rad);
cylinder (h=pot_height+2,r =2*inner_rad, 2*inner_rad);
}