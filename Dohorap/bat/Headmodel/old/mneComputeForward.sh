subjects="02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71"
s=$1
meas="${EXPDIR}dh${s}a/dh${s}a_mc-decision-quick-averageEpochs-c1.fif"
mri="${SUBJECTS_DIR}/dh${s}a/mri/T1-neuromag/sets/COR-dh${s}a-aligned.fif"
bem="${SUBJECTS_DIR}/dh${s}a/bem/dh${s}a-5120-bem-sol.fif"
src="${SUBJECTS_DIR}/dh${s}a/bem/dh${s}a-ico-5-src.fif"
cov="${EXPDIR}dh${s}a/dh${s}a_mc-covariance-c1.fif"
mne_setup_fwdinv.sh ${meas} ${mri} ${bem} ${src} ${cov}
