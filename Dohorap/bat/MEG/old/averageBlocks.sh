subjects="02 03 04 05 06 07 08 09 10 11 12 14 15 16 52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"

conditions="Obj Subj Vis Feed"
suffix="ica"
for subject in $subjects; do
	s=dh${subject}a
	fifDir=${EXPDIR}${s}/
	for condition in $conditions; do
		fifFile=_${condition}_average-${suffix}
		avrfif=${fifDir}/blocks${fifFile}
		singleblockfiles=`/bin/ls ${fifDir}block[12]${fifFile}.fif`
		mne_average_avr.sh --modus weighted ${avrfif}.fif $singleblockfiles
		mne_fif2avr.sh ${avrfif}.fif ${avrfif}
	done
done
