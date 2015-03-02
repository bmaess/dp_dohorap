export EXPDIR=/scr/kuba1/Dohorap/Main/Data/MEG/motionCorrected/
# subjects="dh52a dh53a dh54a dh55a dh56a dh57a dh58a dh59a dh60a dh61a dh62a dh63a dh64a dh65a dh66a dh67a dh68a dh69a dh70a dh71a"
freesurfer=/scr/kuba1/Dohorap/Main/Data/MRI/freesurfer
# for s in $subjects
# do
s="dh52a"
mne_setup_fwdinv.sh $EXPDIR$s/$s-l12h0.4-average-decision_forward.fif $freesurfer/$s/mri/T1-neuromag/sets/COR-$s-aligned.fif $freesurfer/$s/bem/$s-5120-bem-sol.fif $freesurfer/$s/bem/$s-ico-5p-src.fif $EXPDIR$s/$s-l12h0.4-decision-cov.fif
# done
