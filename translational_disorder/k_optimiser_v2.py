#! /Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9
import gemmi
import numpy as np

#Read in reflection file as cctbx any_reflection_file
mtz_name = 'example.mtz'
mtz = gemmi.read_mtz_file(mtz_name)
#Make 2D numpy array with all of the original MTZ data
all_data = np.array(mtz, copy=False)
#Define which columns of all_data to find the initial I and sigI values
I_column = 3
sigI_column = 4
#Define tranlational vector along k (fraction of unit cell length)
td = 0.245
#Calculate corrected I and sigI values for with different k-values
#k_counter = k * 100
k_counter = 0
max_k = 50
#Initalise label list of lists to record labels for final MTZ
label_list = []
while k_counter <= max_k:
	#k_label three digit version of k_counter
	k_label = "{0:0=3d}".format(k_counter)
	label_list.append(["I_{}".format(k_label), "sigI_{}".format(k_label)])
	#Cycle through reflections scaling intensities and sigIs
	k = k_counter / 100
	#mod_I and mod_sI lists will hold modified Is and sigIs. 
	mod_I  = []
	mod_SI = []
	i = 0
	while i < all_data.shape[0]:
		scale =  ((2 * (k ** 2)) - (2 * k) + 1 ) * ( 1 + (((2 * k * (1 - k)) / ((2 * (k ** 2)) - (2 * k) + 1 )) * np.cos(all_data[i,1] * td * 2 * np.pi)))
		mod_I.append(all_data[i,I_column] / scale)
		mod_SI.append(all_data[i,sigI_column] / scale)
		i = i + 1 
	#Make a temporary array then copy all_data and the new modified data into it
	temp_array = np.zeros((all_data.shape[0], all_data.shape[1]+2))
	temp_array[:,:-2] = all_data
	temp_array[:,-2] = mod_I
	temp_array[:,-1] = mod_SI
	all_data = temp_array
	print(k_label)
	k_counter = k_counter + 1

print("{} sets of I and sig I have been added".format(len(label_list)))

#Write data back into new mtz
mtz.add_dataset('corrections')
j = 0
while j < len(label_list):
	mtz.add_column(label_list[j][0], 'J')
	mtz.add_column(label_list[j][1], 'Q')
	j = j + 1
mtz.set_data(all_data)
mtz.write_to_file('k_intensity_corrections.mtz')
