s=$1
conditions="1 2"
for condition in ${conditions}
do
	meas="${EXPDIR}dh${s}a/dh${s}a_mc-decision-averageEpochs-c${condition}.fif"
	inv="${EXPDIR}dh${s}a/dh${s}a__-5120-ico-5-dh${s}a-aligned-inv.fif"
	stc="${EXPDIR}dh${s}a/dh${s}a-decision-c${condition}.stc"
	mne_make_movie --inv ${inv} --meas ${meas} --set 1 --subject "dh${s}a" --morph "dh53a" --smooth 5 --tmin -200 --tmax 2500 --tstep 1 --stc ${stc}
done
