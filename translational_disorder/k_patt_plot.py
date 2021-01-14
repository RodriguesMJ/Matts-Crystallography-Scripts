#! /Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9
#Script to take multi-column MTZ from k_optimiser and plot
#sections of Patterson maps 
#cctbx must be installed / module loaded for Patterson map generation

import subprocess
import numpy as np
import gemmi
import matplotlib
matplotlib.rcParams['text.usetex'] = True
from matplotlib import pyplot as plt

#Input MTZ file name 
mtz_name = 'k_intensity_corrections.mtz'
#High resolution limit
high_res = 2.0
#'y' if you want to generate maps, 'n' if they have already been generated
generate_maps = 'n' 
#Base pattern intensities and sigIs. 
I_base = 'I_'
sig_base = 'sigI_'

k = 0
max_dataset = 50
while k <=50:
	kk = "{0:0=3d}".format(k)
	#Run cctbx.patterson_map to generate Patterson map in CCP4 format 
	resolution_key = 'high_resolution=' + str(high_res)
	file_name_key = 'map_file_name = k_patt_plot_' + str(kk) + '.ccp4'
	label_key = 'labels =' +'\'' + I_base + str(kk) + ',' + sig_base + str(kk) + '\''
	if generate_maps == 'y':
		subprocess.call(['cctbx.patterson_map', mtz_name, file_name_key, label_key, resolution_key])
	else:
		break
	k = k + 1

#Read in CCP4 format Patterson maps as 3D Numpy arrays and 

ccp4 = gemmi.read_ccp4_map('k_patt_plot_000.ccp4')
ccp4.setup()
arr = np.array(ccp4.grid, copy=False)
x = np.linspace(0, ccp4.grid.unit_cell.a, num=arr.shape[0], endpoint=False)
y = np.linspace(0, ccp4.grid.unit_cell.b, num=arr.shape[1], endpoint=False)
plt.plot(y, arr[0,:,0], label='k = 0')

ccp4 = gemmi.read_ccp4_map('k_patt_plot_015.ccp4')
ccp4.setup()
arr = np.array(ccp4.grid, copy=False)
plt.plot(y, arr[0,:,0], label='k = 15')

ccp4 = gemmi.read_ccp4_map('k_patt_plot_018.ccp4')
ccp4.setup()
arr = np.array(ccp4.grid, copy=False)
plt.plot(y, arr[0,:,0], label='k = 18')

ccp4 = gemmi.read_ccp4_map('k_patt_plot_021.ccp4')
ccp4.setup()
arr = np.array(ccp4.grid, copy=False)
plt.plot(y, arr[0,:,0], label='k = 21')

ccp4 = gemmi.read_ccp4_map('k_patt_plot_030.ccp4')
ccp4.setup()
arr = np.array(ccp4.grid, copy=False)
plt.plot(y, arr[0,:,0], label='k = 30')
#Code to make contour plot of Patterson Map, uncomment and de-indent to use 
		#X, Y = np.meshgrid(x, y, indexing='ij')
		#plt.contour(X, Y, arr[:,:,100])
		#plt.gca().set_aspect('equal', adjustable='box')
		#plt.show()
		#print(x,y)
		#print(arr.shape)


plt.grid()
plt.legend()
plt.xlabel(r'\textbf{Interatomic a=0 c =0 b-vectors (Angstroms)}')
plt.ylabel(r'\textbf{Patterson Peak Height}')
plt.show()
