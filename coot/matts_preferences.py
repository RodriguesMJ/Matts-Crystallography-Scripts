#Matts key bindings, mostly stolen from Paul Emsley.

set_show_symmetry_master(1)

set_matrix(20.0)


add_key_binding("Map to 1 sigma","!",
lambda: set_contour_level_in_sigma(scroll_wheel_map(),1))



set_show_environment_distances_h_bonds(1)

set_show_environment_distances(1)
set_show_environment_distances_bumps(0)
set_show_environment_distances_h_bonds(1)


set_refine_ramachandran_angles(1)

set_refine_with_torsion_restraints(1)

add_key_binding("Map plus 0.5 sigma","|",
lambda: step_map_coarse_up(scroll_wheel_map()))

add_key_binding("Map minus 0.5 sigma",":",
lambda: step_map_coarse_down(scroll_wheel_map()))

#****Misc. functions (for keybindings and scripting****
def display_only_active_map():
  active_map=scroll_wheel_map()
  if not map_is_displayed(active_map):
    set_map_displayed(active_map,1)
  displayed_maps_count=0
  for map_id in map_molecule_list():
    displayed_maps_count=displayed_maps_count+map_is_displayed(map_id)
    if (map_is_displayed(map_id)==1) and (map_id!=active_map):
      set_map_displayed(map_id,0)
    if map_is_displayed(map_id):
      displayed_map=map_id
  if displayed_maps_count==1:
    index_displayed=map_molecule_list().index(active_map)
    try:
      next_map=map_molecule_list()[index_displayed+1]
    except IndexError:
      next_map=map_molecule_list()[0]
    set_map_displayed(active_map,0)
    set_map_displayed(next_map,1)
  for map_id in map_molecule_list():
    if map_is_displayed(map_id):
      set_scrollable_map(map_id)
      set_scroll_wheel_map(map_id) #New

def hide_active_mol():
  mol_id=active_residue()[0]
  set_mol_displayed(mol_id,0)

def display_only_active():
  mol_id_active=active_residue()[0]
  displayed_mols_count=0
  for mol_id in model_molecule_list():
    displayed_mols_count=displayed_mols_count+mol_is_displayed(mol_id)
    if (mol_is_displayed(mol_id)==1) and (mol_id!=mol_id_active):
      set_mol_displayed(mol_id,0)
    if mol_is_displayed(mol_id):
      displayed_mol=mol_id
  if displayed_mols_count==1:
    index_displayed=model_molecule_list().index(mol_id_active)
    try: 
      next_mol=model_molecule_list()[index_displayed+1]
    except IndexError:
      next_mol=model_molecule_list()[0]
    set_mol_displayed(displayed_mol,0)
    set_mol_displayed(next_mol,1)
    
def step_map_coarse_up(mol_id):
  current_level=get_contour_level_in_sigma(mol_id)
  if (current_level >= 0.5) and (current_level <= 10.0):
    new_level=current_level+0.1
  elif (current_level<0.5):
    new_level=0.5
  elif (current_level>10.0):
    new_level=10.0
  set_contour_level_in_sigma(mol_id,new_level)

def step_map_coarse_down(mol_id):
  current_level=get_contour_level_in_sigma(mol_id)
  if (current_level >= 0.5) and (current_level <= 10.0):
    new_level=current_level-0.1
  elif (current_level<0.5):
    new_level=0.5
  elif (current_level>10.0):
    new_level=10.0
  set_contour_level_in_sigma(mol_id,new_level)
