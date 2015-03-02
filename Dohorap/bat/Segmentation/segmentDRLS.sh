#!/bin/bash
# requires Freesurfer
basefolder=${MRIDIR}
drlsfolder="${BATDIR}/Segmentation/"
t1="t1mprsagADNI32Ch"
configuration="3"
ln -s -f ${drlsfolder}/drls_helpers/drls.m ./drls.m
ln -s -f ${drlsfolder}/drls_helpers/drlsf.m ./drlsf.m
subject=${1}
segfolder="${basefolder}/${subject}/Segmented"
freesurferfolder="${basefolder}/freesurfer/${subject}/mri"
outfile="${segfolder}/segmented_drls_1mm_cfg${configuration}.nii"
# Rescale TPM and Freesurfer segmentations to 2mm
#tissues="1 2 3 4 5 6"
#for tissue in ${tissues}; do
#	tissuefile="c${tissue}${t1}"
#	echo "Sampling ${segfolder}/${tissuefile} down to 2mm"
#	mri_convert -rt interpolate -vs 2 2 2 -i ${segfolder}/${tissuefile}.nii -o ${segfolder}/${tissuefile}_2mm.nii
#done
if test -f ${freesurferfolder}/aseg.nii; then echo ''; else
	mri_label2vol --seg ${freesurferfolder}/aseg.mgz --temp ${freesurferfolder}/rawavg.mgz --o ${freesurferfolder}/aseg.nii --regheader ${freesurferfolder}/aseg.mgz
fi
#mri_convert -rt interpolate -vs 2 2 2 -i ${freesurferfolder}/aseg.nii -o ${freesurferfolder}/aseg_2mm.nii
echo "Running drls_segment.py"
#ln -s -f ${segfolder}/${t1}_seg8.mat ${segfolder}/${t1}_2mm_seg8.mat
python ${drlsfolder}/drls_segment.py -d ${segfolder} -i ${t1} -a ${freesurferfolder}/aseg.nii -o ${outfile} -c ${drlsfolder}/${configuration}.cfg
rm -f ./drls.m
rm -f ./drlsf.m
