#!/bin/bash 
#Script to autoprocess ICR data collected at the synchrotron or from the Rigaku home source 
 
#Programs used: -DIALS, indexing and integration.
#		-AIMLESS, data reduction
#               -PHASER, molecular replacement
#               -BUSTER, Refinement and water building.
#               -COOT, Real space refinement and ligand fitting.

#Tested with - DIALS version with phenix-1.13-2998
#            - CCP4 version 7.0.0
#            - BUSTER snapshot_20180515 	

#Usage /work/vanmontfort/mrodrigues/processing_scripts/pipeline/BCL6_processing_pipeline.sh ./ICR_pipeline.INP

echo Have you remembered to module load gphl? If not buster will fail so it may be better to abort now \(Control Z\)
echo Waiting 5 seconds...
sleep 5
#Get reference mtz path from input file
REF_MTZ=`grep "REF_MTZ" $1 | cut -c 9-`
IMG_DIR=`grep "IMG_DIR" $1 | cut -c 9-`
FREE_MTZ=`grep "FREE_MTZ" $1 | cut -c 10-`
FREE_LABEL=`grep "FREE_LABEL" $1 | cut -c 12-`
SG=`grep "SG=" $1 | cut -c 4-`
JOB=`grep "JOB=" $1 | cut -c 5-`
XTAL=`grep "XTAL=" $1 | cut -c 6-`
PDB_IN=`grep "PDB_IN=" $1 | cut -c 8-`
PEP_CIF=`grep "PEP_CIF=" $1 | cut -c 9-`

echo The diffraction images should be located in $IMG_DIR
echo  
echo The $FREE_LABEL column will be copied from $FREE_MTZ to the new MTZ
echo
echo $REF_MTZ will be used as a reference to ensure consistent indexing by AIMLESS

HOME_DIR=`pwd`
mkdir "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline
touch "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log

cat $1 >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
#################################### RUN DIALS ###########################################
mkdir "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/DIALS
cd "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/DIALS

IMG_NO=`find $IMG_DIR -not -path '*/\.*' -name "*.img" | sort | wc | awk '{print $1}'`

find $IMG_DIR -not -path '*/\.*' -name "*.img" | sort | rev |cut -c 9- | rev | uniq > ori1.dat
grep -v "MXPress" ori1.dat > ori3.dat
mv ori3.dat ori1.dat

CBF_NO=`find $IMG_DIR -not -path '*/\.*' -name "*.cbf" | sort | wc | awk '{print $1}'`

find $IMG_DIR -not -path '*/\.*' -name "*.cbf" | sort | rev |cut -c 9- | rev | uniq >> ori1.dat
grep -v "MXPress" ori1.dat > ori3.dat
mv ori3.dat ori1.dat
SWEEP_NO=`wc ori1.dat | awk '{print $1}'` 

echo The image directory contains $SWEEP_NO sweeps and a total of $IMG_NO .img images and $CBF_NO .cbf images.


a=1
c=0
while [ $a -le $SWEEP_NO ]
	do
	SWEEP_PATH=`awk "FNR == $a" ori1.dat | rev | cut -d/ -f2- | rev`
	SWEEP_PATTERN=`awk "FNR == $a" ori1.dat | rev | cut -d/ -f 1 | rev`
	

	echo $SWEEP_PATH
	echo $SWEEP_PATTERN
	
	b=`find $SWEEP_PATH -not -path '*/\.*' | grep "$SWEEP_PATTERN" | sed '/log/d' | grep '.cbf\|.img' | grep -v "MXPress" | sort | wc | awk '{print $1}'`


	if [ $b -gt 5 ]
		then
		echo Sweep $a contains $b images and will be imported to DIALS.
		
		find $SWEEP_PATH -not -path '*/\.*' | grep "$SWEEP_PATTERN" | grep -v "MXPress" | grep '.cbf\|.img' | sort >> ori2.dat 		
		#find `awk "FNR == $a" ori1.dat`*>> ori2.dat
		(( c ++ ))
	fi

	if [ $b -le 5 ] 
		then 
		echo Sweep $a contains less than 5 images, images are therefore assumed to be test shots and will be ignored.
	fi


	(( a ++ ))

done

echo There are $c sweeps to import to DIALS and integrate separately.

d=1
while [ $d -le $SWEEP_NO ]
	do
	SWEEP_PATH=`awk "FNR == $d" ori1.dat | rev | cut -d/ -f2- | rev`
	SWEEP_PATTERN=`awk "FNR == $d" ori1.dat | rev | cut -d/ -f 1 | rev`
	da=`printf "%03d" $d`
	mkdir sweep_$da
	cd sweep_$da
	find $SWEEP_PATH -not -path '*/\.*' | grep "$SWEEP_PATTERN" | grep '.cbf\|.img' | sed '/.log/d' | sort >> ori2.dat
	#find $SWEEP_PATH -not -path '*/\.*' | grep "$SWEEP_PATTERN" | sort  | grep "img" >> ori2.dat
	#dials.import `cat ./ori2.dat | rev | cut -c 9- | rev | uniq | awk "FNR == $d"`*
	SWEEP_IMG_NO=`cat ./ori2.dat | wc | awk '{print $1}'`
	
	if [ $SWEEP_IMG_NO -gt 5 ]
		then	
		grep -v "MXPress" ori2.dat > ori3.dat
		mv ori3.dat ori2.dat
		dials.import allow_multiple_sweeps=True < ori2.dat
		#dials.import `cat ../ori2.dat | rev | cut -c 9- | rev | uniq | awk "FNR == $d"`*
	
		dials.find_spots datablock.json nproc=6
		
		if [ $SG -lt 1 ]
			then 
			dials.index datablock.json strong.pickle
		fi

		if [ $SG -ge 1 ]
			then
			dials.index datablock.json strong.pickle space_group=$SG
		fi

		dials.refine experiments.json indexed.pickle scan_varying=true
		dials.plot_scan_varying_crystal refined_experiments.json
		dials.integrate refined_experiments.json refined.pickle nproc=6 background.algorithm=glm
	
		dials.analyse_output integrated.pickle
		dials.report integrated_experiments.json integrated.pickle

		mv dials-report.html dials-report-sweep_$da.html

		echo To see analysis of integration output open ./sweep_$da/dials-report-sweep_$da.html | tee -a "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
	
		dials.export integrated.pickle integrated_experiments.json mtz.hklout=integrated_$da.mtz		
	fi	
	cd -
		
	(( d ++ ))
	

done

cd $HOME_DIR
INT_FILES=`find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/DIALS -name "integrated*mtz" | wc | awk '{print $1}'`

if [ $INT_FILES -lt 1 ]
	then
	echo DIALS produced no integrated files, script will abort.
	echo DIALS produced no integrated files, script will abort. >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
	exit 1
fi

if [ $INT_FILES -gt 0 ]
	then 
	echo DIALS has produced $INT_FILES integrated files to pass to AIMLESS.
	echo DIALS has produced $INT_FILES integrated files to pass to AIMLESS. >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
fi

#################################### EXIT DIALS ##########################################



################################## RUN AIMLESS ###########################################

mkdir "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/AIMLESS 
find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/DIALS -name "integrate*mtz" > "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/AIMLESS/ori4.dat
cd "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/AIMLESS/

e=`wc ori4.dat | awk '{print $1}'`
echo There are $e integrated mtzs to combine in pointless.
echo There are $e integrated mtzs to combine in pointless.  >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
############## POINTLESS

mkdir pointless

cd pointless
touch pointless.inp
f=1
g=`echo $REF_MTZ | wc | awk '{print $3}'`
while [ $f -le $e ]
	do 
	fa=`printf "%03d" $f`
	echo hklin `awk "FNR == $f" ../ori4.dat`         >> pointless.inp
	echo TOLERANCE 10 				 >> pointless.inp
	if [ $f -eq 1 ]
	then
echo hklout pointless_$JOB.mtz                       >> pointless.inp
			if [ $SG -ge 1 ]
               		then
				if [ $g -le 2 ]
                        		then
        				echo SPACEGROUP $SG          >> pointless.inp
        			fi
			fi
	
	
			if [ $g -gt 2 ]
			then
				echo 	HKLREF $REF_MTZ  >> pointless.inp 	
			fi
	fi
 	(( f ++ ))
done

cat pointless.inp >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
pointless <pointless.inp > pointless_$JOB.log
cat pointless_$JOB.log >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log
cd ../


############ AIMLESS 

mkdir aimless
cd aimless

AIM_IN=`find ../ -name "pointless_$JOB.mtz"`
AIM_OUT=./aimless_"$JOB"_001.mtz


	echo hklin $AIM_IN   >  aimless_001.inp
	echo hklout $AIM_OUT >> aimless_001.inp  
	
	aimless < aimless_001.inp  > aimless_"$JOB"_"$XTAL"_001.log

#Read in AIMLESS suggestion for resolution limit based on CC(1/2).


AIM_OUT=./aimless_"$JOB"_002.mtz


        echo hklin $AIM_IN   >  aimless_002.inp
        echo hklout $AIM_OUT >> aimless_002.inp 

AIM_RES=`cat *001.log | grep "half-dataset correlation CC(1/2)" | head -1 | rev | cut -c 3- | rev | cut -c 60-`

	echo RESO HIGH $AIM_RES >> aimless_002.inp
aimless < aimless_002.inp  > aimless_"$JOB"_"$XTAL"_002.log
cat aimless_"$JOB"_"$XTAL"_002.log >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log

	#Clean up AIMLESS folder
	mkdir pass_1
	mkdir pass_2
	mv *001* pass_1
	mv *002* pass_2
	rm *PLOT ROGUES SCALES

#Convert intensities to structure factors with TRUNCATE
mkdir truncate
TRU_IN=`find pass_2/ -name "*mtz"`

echo Converting intensities to amplitudes using TRUNCATE

ctruncate -hklin $TRU_IN -hklout truncate_"$JOB".mtz \
-colin '/*/*/[IMEAN,SIGIMEAN]'<< EOF-trunc > ./truncate_"$JOB"_"$XTAL".log
title Truncate Job $JOB Crystal $XTAL 
labout  F=F SIGF=SIGF
EOF-trunc

mv truncate_"$JOB".mtz truncate
mv ./truncate_"$JOB"_"$XTAL".log truncate
cat truncate/truncate_"$JOB"_"$XTAL".log >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log

###Add Free R

echo Adding Free R flag

#Get symmetry out of Aimless log
AIM_SYM=`grep "Space"  ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 14-`  
SYM_NWS="$(echo "${AIM_SYM}" | tr -d '[:space:]')"

#echo Space group $AIM_SYM or $SYM_NWS with no white space 

cella=`grep cell ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 22- | rev | cut -c 42- | rev`
cellb=`grep cell ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 30- | rev | cut -c 34- | rev`
cellc=`grep cell ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 38- | rev | cut -c 26- | rev`
cellalpha=`grep cell ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 46- | rev | cut -c 18- | rev`
cellbeta=`grep cell ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 54- | rev | cut -c 10- | rev`
cellgamma=`grep cell ./pass_2/aimless_"$JOB"_"$XTAL"_002.log | tail -1 | cut -c 61- | rev | cut -c 2- | rev`

echo $cella $cellb $cellc $cellalpha $cellbeta $cellgamma 

unique hklout ./unique_"$JOB"_"$XTAL".mtz <<EOF > ./FreeR_"$JOB"_"$XTAL".log
SYMMETRY $SYM_NWS
LABOUT F=FUNI SIGF=SIGFUNI
CELL $cella $cellb $cellc $cellalpha $cellbeta $cellgamma
RESOLUTION $AIM_RES
EOF


####Assemble the final MTZ

echo Assembling the final MTZ with CAD

cad hklin1 unique_"$JOB"_"$XTAL".mtz hklin2 ./truncate/truncate_"$JOB".mtz hklin3 $FREE_MTZ hklout cad_"$JOB"_"$XTAL".mtz<<EOF >> ./FreeR_"$JOB"_"$XTAL".log
LABIN FILE 1 ALLIN
LABIN FILE 2 E1 = F E2 = SIGF
LABIN FILE 3 E1 = $FREE_LABEL 
EOF

#Remove FUNI and SIGFUNI from unique
mtzutils hklin cad_"$JOB"_"$XTAL".mtz hklout assembled_"$JOB"_"$XTAL".mtz <<EOF >> ./FreeR_"$JOB"_"$XTAL".log
EXCLUDE FUNI SIGFUNI
EOF


uniqueify -f $FREE_LABEL assembled_"$JOB"_"$XTAL".mtz FINISHED_"$JOB"_"$XTAL".mtz 

cd ../
mkdir logs
cat aimless/pass_2/aimless_"$JOB"_"$XTAL"_002.log >  logs/data_reduction_"$JOB".log
cat aimless/truncate/truncate_"$JOB"_"$XTAL".log >>  logs/data_reduction_"$JOB".log
cat aimless/FreeR_"$JOB"_"$XTAL".log             >>  logs/data_reduction_"$JOB".log


echo Job complete! See ./logs for some summary log files.
echo The data has been processed to a resolution of $AIM_RES Angstroms in spacegroup $AIM_SYM, if you would like to change either of these re-run Aimless using ./pointless/pointless_$JOB.mtz as an input MTZ.

mv ori* logs


cd $HOME_DIR
################################### EXIT AIMLESS #########################################

#################################### RUN PHASER ##########################################
mkdir "$JOB"_"$XTAL"_pipeline/phaser
cd "$JOB"_"$XTAL"_pipeline/phaser
PHASER_MTZ_IN=`find ../AIMLESS -name "*FINISHED*mtz"`

echo The PDB input to phaser is $PDB_IN | tee -a MR.log
echo The MTZ input to phaser is $PHASER_MTZ_IN | tee -a MR.log

echo MODE MR_AUTO                                          > phaser.inp
echo HKLIN $PHASER_MTZ_IN                                 >> phaser.inp
echo LABIN F=F SIGF=SIGF                                  >> phaser.inp
echo SGALTERNATIVE SELECT NONE                            >> phaser.inp
echo ENSEMBLE ensemble1 \& PDB \& "$PDB_IN" \& IDENT 0.95 >> phaser.inp
echo COMPOSITION BY AVERAGE                               >> phaser.inp
echo SEARCH ENSEMBLE ensemble1 NUMBER 1                   >> phaser.inp

phaser < phaser.inp | tee -a MR.log
cat MR.log >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log 
#phaser <EOF >> ./phaser_"$JOB"_"$XTAL".log
#MODE MR_AUTO
#HKLIN $PHASER_MTZ_IN
#LABIN F=F SIGF=SIGF
#SGALTERNATIVE SELECT NONE
#ENSEMBLE ensemble1 & PDB & "$PDB_IN" & IDENT 0.95
#COMPOSITION BY AVERAGE
#SEARCH ENSEMBLE ensemble1 NUMBER 1
#EOF 

cd $HOME_DIR
#################################### EXIT PHASER #########################################

echo PHASER complete

#################################### RUN BUSTER ##########################################

mkdir "$JOB"_"$XTAL"_pipeline/buster
cd "$JOB"_"$XTAL"_pipeline/buster
BUSTER_MTZ_IN=$PHASER_MTZ_IN
BUSTER_PDB_IN=`find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/phaser -name "PHASER*pdb" | head -1`


echo The pdb from PHASER to go into BUSTER is $BUSTER_PDB_IN | tee -a buster.log
echo The mtz from PHASER to go into BUSTER is $BUSTER_MTZ_IN | tee -a buster.log

a=`find ./ -type d -name '*buster' | wc | awk '{print $3}'`

b=$(( $a + 1 ))
ba=`printf "%03d" $b`

c=`echo "$PEP_CIF" | wc | awk '{print $3}'`
if [ $c -ge 5 ]
	then
	echo You have specified that the search model to be used contains a ligand requiring this library file $PEP_CIF	
	refine -p $BUSTER_PDB_IN -m $BUSTER_MTZ_IN -d buster_"$ba" -M TLSbasic -nbig 3 AutomaticFormFactorCorrection=yes StopOnGellySanityCheckError=no -l $PEP_CIF -L | tee -a buster.log
fi

if [ $c -le 5 ]
	then
	echo You have specified that the model from PHASER contains no ligands requiring library files	
	refine -p $BUSTER_PDB_IN -m $BUSTER_MTZ_IN -d buster_"$ba" -M TLSbasic -nbig 5 AutomaticFormFactorCorrection=\"yes\" StopOnGellySanityCheckError=no -L | tee -a buster.log
fi

cat buster.log | grep "best refinement in BUSTER reached for F,SIGF" >> "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log 
####################################### EXIT BUSTER ######################################

cd $HOME


####################################### LAUNCH COOT ######################################

mkdir coot 
cd coot 
COOT_PDB_IN=`find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/buster -name "refine.pdb"`
COOT_MTZ_IN=`find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/buster -name "refine.mtz"`

#Find restraint dictionaries and input to COOT
COOT_LIB_NO=`find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/buster -name "*cif" | wc | awk '{print $1}'`

echo There are $COOT_LIB_NO restraint libraries to input to COOT | tee -a "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log 

#Coot command to just launch coot with mtz and pdb out of buster and guile script to give
#menu option to generate a list of residues with occupancy less than 0.9.


COOT_COM="coot --pdb $COOT_PDB_IN --auto $COOT_MTZ_IN --script /work/vanmontfort/mrodrigues/processing_scripts/coot_guile/partial-occ-nav.scm"

#Addition of library files to coot command to save time looking for them after opening coot
h=1
while [ $h -le $COOT_LIB_NO ]
do 
	i=`find "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/buster -name "*cif" | awk "FNR == $h"`
	i="--dictionary $i"
    COOT_COM="$COOT_COM $i"
    echo $COOT_COM


	(( h ++ ))
done

echo Coot launched with command: $COOT_COM | tee -a "$HOME_DIR"/"$JOB"_"$XTAL"_pipeline/processing_summary.log 

#Launch coot
$COOT_COM




















