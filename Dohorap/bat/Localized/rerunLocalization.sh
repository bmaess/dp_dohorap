# requires MNE and set paths
# total time: 113 minutes

matlabOptions="-nodisplay -nosplash -nodesktop -r"

# Calculate covariances
#python ${BATDIR}/MEG/calculateCovariance.py

# Create the inverse model (10 minutes)
# Don't activate this part, just run it on kuba
#rm -f ${DATDIR}/BEM/dh??a/*
#python ${BATDIR}/Localized/MNEcalculateInverse.py

# Calculate individual average localized activity
rm -f ${DATDIR}/Localized_avg/dh??a/*
rm -f ${DATDIR}/Localized_avg/*
python ${BATDIR}/Localized/MNEcalculateSTCs.py # individual STC files (60-85 minutes)
matlab ${matlabOptions} "run('${BATDIR}/Localized/averageSTC.m')" # group-level STC files (23 minutes)

# Extract ROI-level activity from average activity (21 minutes)
python ${BATDIR}/Localized/combineIndividualSTCinROIs.py # 19:10 minutes
python ${BATDIR}/Localized/combineGroupSTCinROIs.py # 1:40 minutes

# optional: Extract individual, ROI-level single-trial activity
#python ${BATDIR}/Localized/extractROIactivity.py
