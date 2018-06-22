#!/bin/bash  
#Script to run DIALS on single sweep data affected by Debye-Sherrer rings 
#Will only work with data collected on a Pilatus in CBF format.
#Currently only works on single sweep data
#Based on Parkhurst, J. M., et al, IUCRJ, 4, 626-638, 2017. 

################## USER INPUT ###############################################################
#Folder containing images from data collection
IMG_DIR=/data/protein/images/

#Spacegroup number
SPG=178

#Number of processors to use
PROC=4
##############################################################################################

find $IMG_DIR -name "*cbf" | sort | sed '/mesh/d' | sed '/line/d' | sed '/ref/d' > ori1.dat

dials.import < ori1.dat
dials.find_spots datablock.json nproc="$PROC"
dials.index datablock.json strong.pickle space_group="$SPG"
dials.refine experiments.json indexed.pickle scan_varying=true
dials.plot_scan_varying_crystal refined_experiments.json
dials.integrate refined_experiments.json refined.pickle nproc=8 background.algorithm=glm

dials.analyse_output integrated.pickle
dials.report integrated_experiments.json integrated.pickle

dials.model_background integrated_experiments.json

dials.integrate integrated_experiments.json background.algorithm=gmodel background.gmodel.robust.algorithm=True background.gmodel.model=background.pickle nproc=8

dials.analyse_output integrated.pickle  
dials.report integrated_experiments.json integrated.pickle
dials.export integrated.pickle integrated_experiments.json mtz.hklout=integrated_auspex.mtz

