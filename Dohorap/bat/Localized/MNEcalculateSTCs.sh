#!/bin/bash
# Requires 5:18h to run (with 4000 points per datastream)

conditions="Obj Subj"
#subjects="02 03 04 05 06 07 08 09 10 11 12 14 15 16 52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"
morphsubj="dh55a"

s=$1
#for subject in $subjects; do
invDir=${BEMDIR}${s}/
fifDir=${DATDIR}MEG_mc_hp004_ica_l50/${s}/
OUTDIR=${DATDIR}Localized_avg/${s}/
if [ ! -d $OUTDIR ]; then
	mkdir -p $OUTDIR
fi	
invFile=${invDir}${s}__-5120-ico-5p-${s}-aligned-inv.fif
for condition in $conditions; do
	evokedFile=${fifDir}${condition}_average-ave.fif
	outFile=${OUTDIR}${condition}_norm.stc
	options="--set 1 --sLORETA --smooth 4 --tmin -1000 --tmax 3000 --tstep 1"
	mne_make_movie --inv ${invFile} --meas ${evokedFile} --subject ${s} --morph ${morphsubj} --stc ${outFile} ${options}
	outFile=${OUTDIR}${condition}_signed.stc
	mne_make_movie --inv ${invFile} --meas ${evokedFile} --subject ${s} --morph ${morphsubj} --stc ${outFile} ${options} --signed
done
#done
