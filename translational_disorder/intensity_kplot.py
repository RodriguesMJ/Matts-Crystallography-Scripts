#! /Library/Frameworks/Python.framework/Versions/3.9/bin/python3.9
#Modified intensity columns must be labelled I_xxx and sigI_xxx
import numpy as np 
import matplotlib
matplotlib.rcParams['text.usetex'] = True
import matplotlib.pyplot as plt
import gemmi
import pandas as pd

#Read in reflection file as gemmi mtz object
mtz_name = 'k_intensity_corrections.mtz'
mtz = gemmi.read_mtz_file(mtz_name)
#Access data as 2D Numpy Array and Pandas Dataframe
all_data = np.array(mtz, copy=False)
df = pd.DataFrame(data=all_data, columns=mtz.column_labels())

#Get df column names
column_names = list(df.columns)
#List of k indices for every reflection
k_list = np.array(df['K'])
#Note: only modified sigI columns must be labelled starting sigI  
dataset_number = sum('sigI' in s for s in column_names)
print("There are {} datasets with modified intensities".format(dataset_number))
#Make list of columns with the modified I and sigIs
Icolumns    = []
sigIcolumns = []
for row in column_names:
	if "sigI_" in row:
		sigIcolumns.append(row)
for i in sigIcolumns:
	Icolumns.append(i[3:])

#Cycle through columns with modified intensities
dataset_counter = 15
#Max k_index you want to plot up to
max_index = 30
#Np array to hold average Is for each k-index 
#and k_indices
average_corrections = np.arange(0, (max_index + 1), 1).reshape(-1,1)

#while dataset_counter < dataset_number:
while dataset_counter < 22:
	average_I = []

	int_col = Icolumns[dataset_counter]
	#sig_col = sigIcolumns[dataset_counter]
	intensities = np.array(df[int_col])
	k_int = np.array(list(zip(k_list,intensities)))
	index_counter = 0
	while index_counter <= max_index:
		i_stack = []
		for row in k_int:
			if row[0] == index_counter:
				i_stack.append(row[1])
		average_I.append([np.nanmean(np.array(i_stack))])
		index_counter = index_counter + 1
	temp_array = np.zeros((average_corrections.shape[0], (average_corrections.shape[1] + 1)))
	temp_array[:,:-1] = average_corrections
	temp_array[:,-1] = np.ravel(np.array(average_I))
	average_corrections = temp_array
	dataset_counter = dataset_counter + 1


#Plot average intensities along k_axis

plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,1]), label='k=15')

#plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,2]), label='k=16')
plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,3]), label='k=17')
plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,4]), label='k=18')
plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,5]), label='k=19')
plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,6]), label='k=20')
#plt.plot(np.array(average_corrections[:,0]),np.array(average_corrections[:,7]), label='k=21')

plt.grid()
plt.legend()
plt.xlabel(r'\textbf{Layer Index}')
plt.ylabel(r'\textbf{Mean Intensity}')
plt.show()

