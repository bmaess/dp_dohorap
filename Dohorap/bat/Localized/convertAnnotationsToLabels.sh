# Requires the source paths to be set, MNE and Freesurfer
hemispheres="lh rh"
subject="dh55a" # This is the subject with the modified aparc.a2009s
labelDir=${SUBJECTS_DIR}${subject}/label
mkdir -p ${labelDir}
for hemisphere in ${hemispheres}; do
	mri_annotation2label --annotation aparc.a2009s-modified --subject ${subject} --hemi ${hemisphere} --outdir ${labelDir}/annot2009
done
# Link ROIs from created labels into the base label directory
python createFreesurferROIlabels.py

# Morph from dh55a to every other subject
cd ${SUBJECTS_DIR}
subjectlist=`ls -d dh??a`
cd -
for subject in ${subjectlist}; do
	mne_make_morph_maps --from dh55a --to ${subject}
	mne_morph_labels --from dh55a --to ${subject} --labeldir ${labelDir}
	# mne_morph_labels puts the labels in a subdirectory of dh55a/label
	# Move the morphed labels in the correct directory
	newLabelFiles=`ls ${labelDir}/${subject}`
	for newLabelFile in ${newLabelFiles}; do
		mv ${labelDir}/${subject}/${newLabelFile} ${SUBJECTS_DIR}${subject}/label
	done
	for hemisphere in ${hemispheres}; do
		# Link ROIs from Clozep into the base label directory
		refFile="${SUBJECTS_DIR}ClozepLabels/${subject}/aSTG-${hemisphere}.label"
		symFile="${SUBJECTS_DIR}${subject}/label/aSTG-clozep-${hemisphere}.label"
		ln -s ${refFile} ${symFile}
	done
done
