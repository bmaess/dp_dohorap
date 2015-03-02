s=$1
subject="dh${s}a"
mne_setup_bem.sh ${subject} --icosrc 4 --icovol 2 --bem 1
mkheadsurf -s ${subject}
mne_surf2bem --surf ${SUBJECTS_DIR}/${subject}/surf/lh.seghead --id 4 --check --fif ${SUBJECTS_DIR}/${subject}/bem/${subject}-head.fif
