#Load the 5lnr pdb 
load ./5lnr.pdb
set_name 5lnr, pdx1
hide all

#Uncomment to show cartoon_representation
#show cartoon

#Set global cartoon colour
set cartoon_color, white


#Generate symmetry mates to show biological unit
symexp sym, pdx1, all, 5.0
delete sym07000001
delete sym08000000
delete sym07000000
delete sym05000000
delete sym04000000
delete sym050000-1

#Show the surface of pdx1

show surface
set surface_color, palegreen
set transparency, 0.35

#Select ligand, chain A with residue name PLP
select ligand, pdx1 and chain A and resn PLP

#Select binding site
select binding_site, ligand around 6
show st, binding_site


#Color protein by green
util.cbag chain A

#Color ligand by cyan
util.cbay ligand

#Show ligand
show st, ligand

#Set stick and sphere appearances
set stick_radius, 0.175
set sphere_scale, 0.2

#Turn off ray shadows
set ray_shadows, 0
bg_color white

#Set view, use get_view in gui to find the view parameters.

### cut below here and paste into script ###
set_view (\
    -0.863448560,    0.312051028,   -0.396306664,\
    -0.181604385,    0.540658057,    0.821403563,\
     0.470584065,    0.781214356,   -0.410165727,\
     0.000547808,    0.000381056,  -46.811851501,\
    18.199352264,  -24.243328094,  -25.633213043,\
   -16.075893402,  109.702896118,  -20.000000000 )
### cut above here and paste into script ###


#Show hydrogen bonded waters
select water_site, ligand around 3.5 and resn hoh
show sp, water_site
hide st, hydrogen



#distance (prot and chain A and name N3), (chain W and resi 103 and prot)

hide labels

show st, resi 166 and chain A
hide st, hydrogen

hide st, name c+o+n and not resn PLP
