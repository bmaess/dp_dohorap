#!/bin/bash
# $Id: MNE_estimates_stc.sh 2911 2014-02-18 16:37:47Z maess $

# set 1

conditions="Obj Subj Vis Feed"
subjects="02 03 04 05 06 07 08 09 10 11 12 14 15 16 52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"
morphsubj="dh58a"
method="sLORETA"
prefix="_mc_hp004_l80"
suffix="ica"

makecfg=${CFGDIR}mne_subject_estimates_stc_Makefile.cfg
makeFile=${BATDIR}Localized/mne_subject_estimates_stc_Makefile
for subject in $subjects; do
	s=dh${subject}a
	fifDir=${EXPDIR}${s}/
	OUTDIR=${DATDIR}Localized/${s}/
	if [ ! -d $OUTDIR ]; then
		mkdir -p $OUTDIR
	fi	
	invFile=${fifDir}${s}__-5120-ico-5p-${s}-aligned-inv.fif
	for condition in $conditions; do
		fifFile=${prefix}_${condition}_average-ica
		singleblockfiles=`/bin/ls ${fifDir}${s}[12]${fifFile}.fif`
		evokedFile=${EXPDIR}${s}/${s}${prefix}_${condition}_average-${suffix}.fif
		outFile=${OUTDIR}lh${prefix}_${condition}_average-${suffix}.stc
		mne_make_movie --inv ${invFile} --meas ${evokedFile} --set 1 --sLORETA --subject ${s} --morph ${morphsubj} --smooth 5 --tmin -500 --tmax 2000 --tstep 5 --stc ${outFile}
	done
done
