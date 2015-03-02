subjects=`ls ${LOCDIR}`
metric="signed"
options="--smooth 5 --lh --width 1280 --height 800 --sLORETA --fthresh 0.5 --fmid 1.8 --fmax 4.0 --tmin -500 --tmax 2500 --tstep 10"
conds="Obj Subj"
hemispheres="lh rh"

for hemi in ${hemispheres}; do
	for cond in ${conds}; do
		for subject in ${subjects}; do
			filestem=${LOCDIR}${subject}/${cond}_${metric}-lh
			mne_make_movie --subject ${subject} ${options} --stcin ${filestem}.stc --mov ${filestem}.mov
		done
	done
done
