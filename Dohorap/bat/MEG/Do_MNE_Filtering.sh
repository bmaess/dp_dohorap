#!/bin/bash
# always execute this first:
# source bat/start.sh
# freesurfer
# MNE -v 2.7.3
export MNE_VERBOSE=0
export COMPUTINGHOST=`hostname`

kids="dh01a dh02a dh03a dh04a dh05a dh06a dh07a dh08a dh09a dh10a dh11a dh12a dh13a dh14a dh15a dh16a dh17a dh18a dh19a"
adults="dh52a dh53a dh54a dh55a dh56a dh57a dh58a dh59a dh60a dh61a dh62a dh63a dh64a dh65a dh66a dh67a dh68a dh69a dh70a dh71a"

subjects="$kids $adults"
blocks="1 2"

export MATLABPATH=~maess/matlab/MNE:${BATDIR}MEG:/afs/cbs.mpg.de/software/mne/2.7.4-3435/amd64/share/matlab
for s in $subjects; do
	for b in $blocks; do
		out1=${DATDIR}MEG_mc_hp004/${s}/block${b}.fif
		baseout1=`basename $out1`
		export LOCKFIF=${LOCKDIR}${baseout1}.lock
		if [ ! -h ${LOCKFIF} ]; then
			ln -s ${COMPUTINGHOST}.$$$$ ${LOCKFIF}
			make -rf ${BATDIR}MEG/Filter_FIFF_Makefile IN=${EVEDIR}${s}/block${b}.fif OUT=${out1} COEFF=${BATDIR}MEG/hp_004_4367pts_1000Hz.fir
			/bin/rm ${LOCKFIF}; 
		else 
			echo "Job is already running (remove the lock if not): `readlink ${LOCKFIF}`"; 
		fi
	done
done


