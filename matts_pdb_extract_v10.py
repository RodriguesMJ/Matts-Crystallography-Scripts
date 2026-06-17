#!/usr/bin/env python3.5
####################################### USER INPUT #########################################
REF_PROG = "BUSTER"
MODEL_DIR = "/home/mrodrigues/processing_link/BCL6/ligand_radiolysis/I24_20170731/dials_proc_170825/CCT368375_2/dose_refinement_180315/occ//**/refine.pdb"

INT_PROG = "DIALS"

SCAL_PROG = "AIMLESS"
SCALE_LOG_DIR = "/home/mrodrigues/processing_link/BCL6/ligand_radiolysis/I24_20170731/dials_proc_170825/DLS/CCT368375_2/aimless//**/sweep_.log"

#Only the MR log file for sweep 1 is required 
MR_PROG = "PHASER" 
MR_LOG = "../ccp4/1_phaser_MR.log"

#Base log_script file 
log_script = "matts_log_script.inp"

#Template .cif file, to be filled out new for each group.
template = "matts_data_template.cif"

#Dose per dataset in units of MGy
DPD = 1.74

#Stucture title (XXX for dose place holder)
title = "Crystal Structure of B-cell lymphoma 6 protein BTB domain in complex with ligand 1 at XXX MGy X-ray dose."
############################################################################################
import glob
import sys
import subprocess
import re
import fileinput

model_paths = []
for filename in glob.iglob(MODEL_DIR, recursive=True):
  model_paths.append(filename)
model_paths.sort()

mtz_paths = []
for filename in glob.iglob(SCALE_LOG_DIR, recursive=True):
  mtz_paths.append(filename)
mtz_paths.sort()

print("{} was used for integration.".format(INT_PROG))
print("{} was used for data scaling.".format(SCAL_PROG))
print("{} was used for molecular replacement.".format(MR_PROG))
print("{} was used to refine the model.".format(REF_PROG))

a = len(mtz_paths)
b = len(model_paths)

if a != b:	
  print("Number of scaling log files does not equal number of model files.")
  sys.exit()

if a == b:	
  print("There are {} scaling log files and {} refined model files, continue.".format(a, b))

c = 0 
while c < a:
  #Edit data template cif file in place rather than log_script.
  d = c + 1
  da = "{0:0=3d}".format(d)
  new_template = 'data_template_' + da + '.inp'
  model_cif_out = 'pdb_extract_' + da + '.mmcif'
	SF_cif_out = 'SF_pdb_extract_' + da + '.mmcif'
	txt1 = template
	s = open(txt1).read()	
	title1 = title.split('XXX')[0]
	title2 = title.split('XXX')[1] 
	dose = DPD * d
	dose = '%.2f' % dose
	dose = str(dose)
	new_title = title1 + dose + title2
	#print(new_title)
	for line in s.split('\n'):
	  if "_struct.title" in line:
		  line1 = line.split(' ')[0]
		  line1 = line1 + '          ' + r"'" + new_title + r"'"
			change_title = line1
			s = s.replace(line, change_title) 
	template_out = 'data_template_' + da + '.cif'
	print(template_out)
	e = open(template_out, 'w')
	e.write(s)	
	c += 1
# 	
log_temp = "data_template_*.cif"
extract_inputs = []
for filename in glob.iglob(log_temp, recursive=True):
    extract_inputs.append(filename)
extract_inputs.sort()
e = len(extract_inputs)
print("There are {} input log_script files, continue.".format(e))
f = 0 
while f < e:
	g = f + 1
	ga = "{0:0=3d}".format(g)
	extract_INP = extract_inputs[f]
	PDB_IN = model_paths[f]
	CIF_OUT = 'pdb_extract_' + ga + '.mmcif'
	SCALE_LOG = mtz_paths[f] 
	ref_mtz = model_paths[f]
	ref_mtz = ref_mtz.split('.pdb')[0]
	ref_mtz = ref_mtz + '.mtz'
	sf_out = 'sf_extract_' + ga + '.mmcif'
	if f == 0:
		proc = subprocess.run(["pdb_extract", "-r", REF_PROG, "-iPDB", PDB_IN, "-iENT", extract_INP, "-i", INT_PROG, "-s", SCAL_PROG, "-iLOG", SCALE_LOG, "-m", MR_PROG, "-iLOG", MR_LOG, "-o", CIF_OUT ])
	if f != 0:
		proc = subprocess.run(["pdb_extract", "-r", REF_PROG, "-iPDB", PDB_IN, "-iENT", extract_INP, "-i", INT_PROG, "-s", SCAL_PROG, "-iLOG", SCALE_LOG, "-m", REF_PROG, "-o", CIF_OUT ])
	#Run pdb_extract_sf
	proc = subprocess.run(["pdb_extract_sf", "-idat", ref_mtz, "-o", sf_out])
	#Add wavelength into structure factor mmcif
	txt2 = sf_out
	y = open(CIF_OUT).read()
	for line in y.split('\n'):
		if "_diffrn_radiation_wavelength.wavelength" in line:
			wavelength = ' '.join(line.split())
			wavelength = wavelength.split(' ')[1]
	v = open(txt2).read()
	for line in v.split('\n'):
		if "_diffrn_radiation_wavelength.wavelength   ." in line:
			line1 = line.split(' ')[0]
			line1 = line1 + '   ' + wavelength
			v = v.replace(line, line1)
	new_sf_cif = 'new_sf_' + ga + '.mmcif'
	x = open(sf_out, 'w')
	x.write(v)
	#Add data reduction line to structure cif if missing
	counter = 0
	MR_counter = 0
	for line in y.split('\n'):
		if "data reduction" in line:
			counter = counter + 1
	print("There are {} lines stating the data reduction program.".format(counter))
	for line in y.split('\n'):
			if "phasing " in line:
				MR_counter = MR_counter + 1
	if counter == 0:
		for line in y.split('\n'):
			if not "data scaling" in line:
	 			old_scale_prog1 = line
			if "data scaling" in line:
				old_scale_prog2 = line
				print(old_scale_prog1)
				print(old_scale_prog2)
				red_prog_no = old_scale_prog1.split(' ')[0]
				scale_prog_no = red_prog_no
				if MR_counter > 0:
					red_prog_no = int(red_prog_no) + 3
				if MR_counter == 0:
					red_prog_no = int(red_prog_no) + 2
				red_prog_no = str(red_prog_no)
				red_prog1 = old_scale_prog1.replace(scale_prog_no, red_prog_no, 1)
				red_prog1 = red_prog1 + '\n'
				red_prog2 = old_scale_prog2.replace('data scaling', 'data reduction')
				red_prog2 =red_prog2 + '\n'
		with open(CIF_OUT, "r") as in_file:
			buf = in_file.readlines()
		with open(CIF_OUT, "w") as out_file:
			for line in buf:
				if "data scaling" in line:
					line = line + red_prog1 + red_prog2
				out_file.write(line)
		out_file.close()
		#Check for phasing line and add in buster fourier synthesis line if absent 	
		counter = 0 
		for line in y.split('\n'):
			if "phasing " in line:
				counter = counter + 1
		print("There are {} lines stating the molecular replacement program.".format(counter))
		if counter == 0:
			for line in y.split('\n'):
				if not "REMARK" in line:
					if not "refinement" in line:
						pre_refine_line = line
					if "refinement" in line:
						refine_line = line
						print(pre_refine_line)
						print(refine_line)
						mr_line_no = pre_refine_line.split(' ')[0]
						ref_line_no = str(int(mr_line_no) + 4)
						mr_line1 = pre_refine_line.replace(mr_line_no, ref_line_no, 1)
						mr_line1 = mr_line1 + '\n'
						mr_line2 = refine_line.replace("refinement", "phasing")
						mr_line2 = mr_line2 + '\n' 
			with open(CIF_OUT, "r") as in_file:
				buf = in_file.readlines()
			with open(CIF_OUT, "w") as out_file:
				for line in buf:
					if "data reduction" in line:
						line = line + mr_line1 + mr_line2
						print('There it is!')
					out_file.write(line)
			out_file.close()	
			with open(CIF_OUT) as z:
				lines = z.read().replace("MOLECULAR REPLACEMENT","FOURIER SYNTHESIS")
			with open(CIF_OUT, "w") as z1:
				z1.write(lines)			
	f += 1
# 
