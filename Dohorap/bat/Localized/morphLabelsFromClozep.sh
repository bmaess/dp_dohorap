# Requires the source paths to be set, and MNE
cd ${SUBJECTS_DIR}
subjectlist=`ls -d dh??a`
for subject in ${subjectlist}; do
	mne_make_morph_maps --from dp02a --to ${subject}
	mne_morph_labels --from dp02a --to ${subject} --labeldir ${SUBJECTS_DIR}ClozepLabels
done
cd -
