kids="dh02a dh03a dh04a dh05a dh06a dh07a dh08a dh09a dh10a dh11a dh12a dh13a dh14a dh15a dh16a dh17a dh18a dh19a"
adults="dh52a dh53a dh54a dh55a dh56a dh57a dh58a dh59a dh60a dh61a dh62a dh63a dh64a dh65a dh66a dh67a dh68a dh69a dh70a dh71a"
subjects="$kids $adults"

options="-in 8 -out 3 -ctc /neuro/databases/ctc/ct_sparse.fif -cal /neuro/databases/sss/sss_cal.dat -force -autobad on"

for subject in ${subjects}; do
	/neuro/bin/util/maxfilter -gui -f ${DATDIR}/MEG/${subject}/${subject}a.fif -o ${DATDIR}/MEG_mc/${subject}/emptyRoomAfter.fif ${options}
	/neuro/bin/util/maxfilter -gui -f ${DATDIR}/MEG/${subject}/${subject}p.fif -o ${DATDIR}/MEG_mc/${subject}/emptyRoomPrevious.fif ${options}
done
