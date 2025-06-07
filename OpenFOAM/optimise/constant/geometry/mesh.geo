// Gmsh project created on Mon Feb 24 22:23:49 2025
SetFactory("OpenCASCADE");
//+
Box(1) = {-2, -2, -2, 4, 4, 4};
//+
Physical Surface("inlet", 13) = {1};
//+
Physical Surface("outlet", 14) = {2};
//+
Physical Surface("walls", 15) = {4, 6, 5, 3};
//+
Physical Volume("internal", 16) = {1};
