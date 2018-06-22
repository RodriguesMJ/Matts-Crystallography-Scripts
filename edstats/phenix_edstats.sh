#!/bin/bash 

#Script to run edstats on multiple datasets that have been refined with BUSTER.
#The column labels output by Buster are not compatible with EDSTATS, the script
#uses phenix.maps to generate Fo-Fc and 2Fo-Fc maps with no missing reflections. 
#The maps re converted to ccp4 format with FFT to make the maps compatible with
#edstats. 

#The script will loop through all refinements in subdirectories of $WDIR, useful for 
#dose series.

#CCP4 7.0.0 
#Buster snapshot 20180515 
######################################### USER INPUT ####################################################

#Define the directory in which to search for refine.pdb
WDIR=/work/directory-with-refined-models_pdbs/

LOW_RES=30.0
HI_RES=1.75

##################################### END USER INPUT ##################################################

find $WDIR -name "refine.pdb" | sort > ori1.dat


a=`wc ori1.dat | awk '{print $1}'`

b=1
while [ $b -le $a ]
#while [ $b -le 1 ]
do
	ba=`printf "%03d" $b`
	
	c=$(dirname `awk "FNR == $b" ori1.dat`)
	
	echo Dataset $ba is in folder $c 


		
	cp "$c"/refine.mtz ./phenix_maps_input.mtz	
	cp "$c"/refine.pdb ./phenix_maps_input.pdb	
    #mv maps.params previous_map.params

    echo "  "maps {                                                       >  tmp1
    echo "    "input {                                                    >> tmp1
	echo "     "pdb_file_name = phenix_maps_input.pdb                     >> tmp1
	echo "     "reflection_data "{"                                       >> tmp1  
	echo "       "file_name = phenix_maps_input.mtz                       >> tmp1	
	echo "       "labels = F_"$ba",SIGF_"$ba"                             >> tmp1
	echo "       "high_resolution = None                                  >> tmp1 
    echo "       "low_resolution = None                                   >> tmp1
    echo "       "outliers_rejection = True                               >> tmp1  
    echo "       "french_wilson_scale = True                              >> tmp1
    echo "       "french_wilson {                                         >> tmp1
    echo "          "max_bins = 60                                        >> tmp1   
    echo "          "min_bin_size = 40                                    >> tmp1 
    echo "       ""}"                                                     >> tmp1
    echo "       "sigma_fobs_rejection_criterion = None                   >> tmp1
    echo "       "sigma_iobs_rejection_criterion = None                   >> tmp1
	echo "       "r_free_flags {                                          >> tmp1
    echo "         "file_name = phenix_maps_input.mtz                     >> tmp1
    echo "         "label = FreeR_flag                                    >> tmp1
    echo "         "test_flag_value = 0                                   >> tmp1
    echo "         "ignore_r_free_flags = False                           >> tmp1
    echo "     ""}"                                                       >> tmp1
    echo "   ""}"                                                         >> tmp1 
    echo " ""}"                                                           >> tmp1
	echo " "output "{"                                                    >> tmp1 
    echo "     "directory = "./"                                           >> tmp1
    echo "     "prefix = "$ba"                                            >> tmp1
    echo "     "job_title = None                                          >> tmp1
    echo "     "fmodel_data_file_format = mtz                             >> tmp1 
    echo "     "include_r_free_flags = False                              >> tmp1  
    echo " ""}"                                                           >> tmp1   
    echo " "scattering_table = wk1995 it1992 *n_gaussian neutron electron >> tmp1
    echo "     "wavelength = None                                         >> tmp1
    echo "     "bulk_solvent_correction = True                            >> tmp1 
    echo "     "anisotropic_scaling = True                                >> tmp1
    echo "     "skip_twin_detection = False                               >> tmp1  
    echo " "omit "{"                                                      >> tmp1
    echo "     "method = *simple                                          >> tmp1
    echo "     "selection = None                                          >> tmp1
    echo " ""}"                                                           >> tmp1
	echo                                                                  >> tmp1
	echo " "map_coefficients "{"                                          >> tmp1                                    
    echo "     "map_type = 2mFo-DFc                                       >> tmp1
    echo "     "format = "*mtz" phs                                       >> tmp1
    echo "     "mtz_label_amplitudes = 2FOFCWT                            >> tmp1 
    echo "     "mtz_label_phases = PH2FOFCWT                              >> tmp1  
    echo "     "fill_missing_f_obs = False                                >> tmp1 
    echo "     "sharpening = False                                        >> tmp1
    echo "     "sharpening_b_factor = None                                >> tmp1
    echo "     "exclude_free_r_reflections = False                        >> tmp1 
    echo "     "isotropize = True                                         >> tmp1 
    echo "   ""}"                                                         >> tmp1 
    echo "     "map_coefficients "{"                                      >> tmp1
    echo "     "map_type = 2mFo-DFc                                       >> tmp1 
    echo "     "format = "*mtz" phs                                       >> tmp1
    echo "     "mtz_label_amplitudes = 2FOFCWT_fill                       >> tmp1 
    echo "     "mtz_label_phases = PH2FOFCWT_fill                         >> tmp1
    echo "     "fill_missing_f_obs = True                                 >> tmp1
    echo "     "sharpening = False                                        >> tmp1
    echo "     "sharpening_b_factor = None                                >> tmp1 
    echo "     "exclude_free_r_reflections = False                        >> tmp1  
    echo "     "isotropize = True                                         >> tmp1
    echo "    ""}"                                                        >> tmp1
    echo "     "map_coefficients "{"                                      >> tmp1
    echo "     "map_type = mFo-DFc                                        >> tmp1
    echo "     "format = "*mtz" phs                                       >> tmp1
    echo "     "mtz_label_amplitudes = FOFCWT                             >> tmp1 
    echo "     "mtz_label_phases = PHFOFCWT                               >> tmp1 
    echo "     "fill_missing_f_obs = False                                >> tmp1
    echo "     "sharpening = False                                        >> tmp1 
    echo "     "sharpening_b_factor = None                                >> tmp1   
    echo "     "exclude_free_r_reflections = False                        >> tmp1
    echo "     "isotropize = True                                         >> tmp1
    echo "     ""}"                                                       >> tmp1  
    echo " "map "{"                                                       >> tmp1 
    echo "     "map_type = 2mFo-DFc                                       >> tmp1
    echo "     "format = xplor "*ccp4"                                    >> tmp1
    echo "     "file_name = None                                          >> tmp1 
    echo "     "fill_missing_f_obs = False                                >> tmp1 
    echo "     "grid_resolution_factor = 1/4.                             >> tmp1 
    echo "     "region = *selection cell                                  >> tmp1
    echo "     "atom_selection = None                                     >> tmp1
    echo "     "atom_selection_buffer = 3                                 >> tmp1
    echo "     "sharpening = False                                        >> tmp1
    echo "     "sharpening_b_factor = None                                >> tmp1 
    echo "     "exclude_free_r_reflections = False                        >> tmp1
    echo "     "isotropize = True                                         >> tmp1
    echo " ""}"                                                           >> tmp1 
    echo " "map "{"                                                       >> tmp1  
    echo "     "map_type = mFo-DFc                                        >> tmp1
    echo "     "format = xplor "*ccp4"                                    >> tmp1
    echo "     "file_name = None                                          >> tmp1 
    echo "     "fill_missing_f_obs = False                                >> tmp1 
    echo "     "grid_resolution_factor = 1/4.                             >> tmp1 
    echo "     "region = *selection cell                                  >> tmp1  
    echo "     "atom_selection = None                                     >> tmp1 
    echo "     "atom_selection_buffer = 3                                 >> tmp1
    echo "     "sharpening = False                                        >> tmp1
    echo "     "sharpening_b_factor = None                                >> tmp1
    echo "     "exclude_free_r_reflections = False                        >> tmp1
    echo "     "isotropize = True                                         >> tmp1
    echo "    ""}"                                                        >> tmp1
    echo "   ""}"                                                         >> tmp1

	mv tmp1 maps.params
	
	phenix.maps maps.params
	
	
fft HKLIN ./"$ba"_map_coeffs.mtz MAPOUT FFT_"$ba"_mFo-dFc.map.ccp4<<EOF >> FFT_"$ba".log
xyzlim asu
scale F1 1.0
GRID SAMPLE 4
labin -
    F1=FOFCWT PHI=PHFOFCWT
EOF
	
fft HKLIN ./"$ba"_map_coeffs.mtz MAPOUT FFT_"$ba"_m2Fo-dFc.map.ccp4<<EOF >> FFT_"$ba".log
xyzlim asu
scale F1 1.0
GRID SAMPLE 4
labin -
F1=2FOFCWT PHI=PH2FOFCWT
EOF
	
mv ./phenix_maps_input.mtz ./phenix_maps_input_"$ba".mtz
mv ./phenix_maps_input.pdb ./phenix_maps_input_"$ba".pdb


edstats XYZIN ./phenix_maps_input_"$ba".pdb MAPIN1 FFT_"$ba"_m2Fo-dFc.map.ccp4 MAPIN2 FFT_"$ba"_mFo-dFc.map.ccp4 OUT stats_"$ba".out<<EOF
resl=$LOW_RES
resh=$HI_RES
EOF


(( b ++ ))

done



