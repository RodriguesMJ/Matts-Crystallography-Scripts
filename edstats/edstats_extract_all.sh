#!/bin/bash

#Script to extract stats from EDSTATS output files and list against dataset number/ DWD
#Used to monitor change in local metrics of the fit of the model to electron density with
#X-ray dose.
#To be run after phenix_edstats.sh which output the stats_???.out text files that this
#script uses as an input.
##################################### USER INPUT #########################################

#Directory containing ESDSTATS stats_???.out files
WDIR=/work/prot/edstats/

#Diffraction Weighted Dose per Dataset (from RADDOSE-3D)
DPD=1.00

#Compound name
CMP=compound

#Residue name
RESI=ALA

#Do you want stats for all atoms (3), main chain only (1) or side chain only (2)?
SELE=3

#Tell the script which line in stats*.out your residue of interest is.
LINE=5

#Name of output file (will be written in $WDIR)
#OUTPUT=protein_resnum_stat_STAT1.txt

#Ligand occupancy refinement protocol (occ or no_occ?).
OCC=no_occ
################################### END USER INPUT #######################################

if [ $SELE -eq 1 ]
	then
	SELE_NAME=MAIN
fi

if [ $SELE -eq 2 ]
	then
	SELE_NAME=SIDE
fi

if [ $SELE -eq 3 ]
	then
	SELE_NAME=ALL
fi



OUT_DIR="$WDIR"/EDSTATS_"$SELE_NAME"_"$CMP"_"$RESI"
mkdir $OUT_DIR

STAT=1
while [ $STAT -le 12 ]
	do
	#Which stat do you want sent to output 
        # 1. BAm:   Weighted average Biso.
        # 2. NPm:   No of statistically independent grid points covered by atoms.
        # 3. Rm:    Real-space R factor (RSR).
        # 4. RGm:   Real-space RG factor (RSRG).
        # 5. SRGm:  Standard uncertainty of RSRG.
        # 6. CCSm:  Real-space sample correlation coefficient (RSCC).
        # 7. CCPm:  Real-space 'population' correlation coefficient (RSPCC).
        # 8. ZCCPm: Z-score of real-space correlation coefficient.
        # 9. ZOm:   Real-space Zobs score (RSZO).
        #10. ZDm:   Real-space Zdiff score (RSZD) i.e. max(-RSZD-,RSZD+).
        #11. ZD-m:  Real-space Zdiff score for negative differences (RSZD-).
        #12. ZD+m:  Real-space Zdiff score for positive differences (RSZD+).
	
	if [ $STAT -eq 1 ]
		then
		STAT_NAME=AVEB
	fi
	if [ $STAT -eq 2 ]
		then
		STAT_NAME=GPOINTS
	fi
	if [ $STAT -eq 3 ]
		then
		STAT_NAME=R
	fi
	if [ $STAT -eq 4 ]
		then
		STAT_NAME=RG
	fi
	if [ $STAT -eq 5 ]
		then
		STAT_NAME=SRFG	
	fi
	if [ $STAT -eq 6 ]
		then
		STAT_NAME=CCS
	fi
	if [ $STAT -eq 7 ]
		then
		STAT_NAME=CCP
	fi
	if [ $STAT -eq 8 ]
		then
		STAT_NAME=ZCCP
	fi
	if [ $STAT -eq 9 ]
		then
		STAT_NAME=RSZO
	fi
	if [ $STAT -eq 10 ]
		then
		STAT_NAME=RSZD
	fi
	if [ $STAT -eq 11 ]
		then
		STAT_NAME=RSZDminus
	fi
	if [ $STAT -eq 12 ]
		then
		STAT_NAME=RSZDplus
	fi
	
	
	#Decide which column to read
	if [ $SELE -eq 1 ]
		then
		COL=$(( $STAT + 3 ))
	fi

	if [ $SELE -eq 2 ]
		then	
		COL=$(( $STAT + 15 ))
	fi

	if [ $SELE -eq 3 ]
		then	
		COL=$(( $STAT + 27 ))
	fi

	OUTPUT_FILE="$OUT_DIR"/"$CMP"_"$RESI"_"$SELE_NAME"_"$OCC"_"$STAT_NAME"_STAT_"$STAT".txt	
	
	find $WDIR -name "stats*.out" | sort > ori1.dat

	a=`wc ori1.dat | awk '{print $1}'`

	echo There are $a EDSTATS files.
	
	
	b=1 

	while [ $b -le $a ]

		do
	
	
		ba=`printf "%03d" $b`
	
		DOSE=$(echo "scale=2; $DPD*$b" | bc -l)
	
		dose_fig=${#DOSE}
	
		STAT_FILE=`awk "FNR == $b" ori1.dat`
	
		METRIC=`head -"$LINE" $STAT_FILE | tail -1 | tr -s " " | cut -d ' ' -f $COL` 
	
		if [ $dose_fig -eq 4 ]
			then
			if [ $b -eq 1 ]
				then			
				echo $ba" "$DOSE"   "$METRIC > "$OUTPUT_FILE"
			fi
			if [ $b -gt 1 ]
				then			
				echo $ba" "$DOSE"   "$METRIC >> "$OUTPUT_FILE"
			fi
		fi
	
		if [ $dose_fig -eq 5 ]
			then
			if [ $b -eq 1 ]
				then
	    		echo $ba" "$DOSE"  "$METRIC > "$OUTPUT_FILE"
			fi
			if [ $b -gt 1 ]
				then			
				echo $ba" "$DOSE"  "$METRIC >> "$OUTPUT_FILE"
			fi		
		fi
	
		if [ $dose_fig -eq 6 ]
			then
			if [ $b -eq 1 ]
				then
	    		echo $ba" "$DOSE" "$METRIC > "$OUTPUT_FILE"
			fi
			if [ $b -gt 1 ]
				then			
				echo $ba" "$DOSE" "$METRIC >> "$OUTPUT_FILE"
			fi		
		fi
	
		(( b ++ ))
		done 

    (( STAT ++ ))
done
