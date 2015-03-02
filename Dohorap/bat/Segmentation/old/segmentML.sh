#!/bin/bash
# requires Freesurfer
basefolder="/scr/kuba2/Dohorap/Main/Data/MRI"
mlfolder="/scr/kuba1/automatedsegmentation/ML"
subjectIDs="52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"
t1="t1mprsagADNI32Ch"
subfolder="Segmented"
tissues="1 2 3 4 5 6"
configuration="1"
ln -s ${drlsfolder}/drls.m ./drls.m
ln -s ${drlsfolder}/drlsf.m ./drlsf.m
for subjectID in ${subjectIDs}; do
	subject="dh${subjectID}a"
	segfolder="${basefolder}/${subject}/${subfolder}"
	freesurferfolder="${basefolder}/freesurfer/${subject}/mri"
	outfile="${segfolder}/segmented_ml.nii"
	# Rescale TPM and Freesurfer segmentations to 2mm
	for tissue in ${tissues}; do
		tissuefile="c${tissue}${t1}"
		if test -f  ${segfolder}/${tissuefile}_2mm.nii; then echo ''; else
			echo "Sampling ${segfolder}/${tissuefile} down to 2mm"
			mri_convert -rt interpolate -vs 2 2 2 -i ${segfolder}/${tissuefile}.nii -o ${segfolder}/${tissuefile}_2mm.nii
		fi
	done
	a="${segfolder}/c"
	b="${t1}_2mm.nii"
	if test -f ${segfolder}/tissues_2mm_combined.nii; then echo ''; else
		fslmerge -t ${segfolder}/tissues_2mm_combined.nii.gz ${a}6${b} ${a}1${b} ${a}2${b} ${a}3${b} ${a}4${b} ${a}5${b}
		gunzip ${segfolder}/tissues_2mm_combined.nii.gz
	fi
	echo "Running ML.py"
	python ${mlfolder}/ML.py -i ${segfolder}/tissues_2mm_combined.nii -o ${outfile}
done
