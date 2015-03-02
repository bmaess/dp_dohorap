# takes 11:20 min for all subjects

export morphsubj=dh55a
export method=sLORETA
export EXPDIR=${BEMDIR} # This sets the output directory for mneSetupFwdInv.sh

subject=${1}
freesurferDir=${SUBJECTS_DIR}${subject}
evokedDir=${DATDIR}/MEG_mc_hp004_ica_l50/${subject}
outDir=${BEMDIR}${subject}
if [ ! -d ${outDir} ]; then
	mkdir -p ${outDir}
fi
evokedFile=${evokedDir}/Vis_average-ave.fif
mriFile=${freesurferDir}/mri/T1-neuromag/sets/COR-${subject}-aligned.fif
bemFile=${freesurferDir}/bem/${subject}-5120-bem.fif
srcFile=${freesurferDir}/bem/${subject}-ico-5p-src.fif
#covFile="${DATDIR}Covariances_from_Clozep/average-cov.fif"
covFile=${evokedDir}/Vis-cov.fif
#covFile=${evokedDir}/Feed-cov.fif
#covFile=${evokedDir}/Vis_corr-cov.fif
#covFile=${DATDIR}/MEG_mc_hp004_ica_l50/kids-Vis_corr-cov.fif
#covFile=${DATDIR}/MEG_mc_hp004_ica_l50/kids-Vis_corr2-cov.fif (fails catastrophically)
# covFile=${DATDIR}/MEG_mc_hp004/${subject}/block1-cov.fif (never attempted)
megReg=${2}

${BATDIR}/Localized/mneSetupFwdInv.sh ${evokedFile} ${mriFile} ${bemFile} ${srcFile} ${megReg} ${covFile}
