kids="dh02a dh03a dh04a dh05a dh06a dh07a dh08a dh09a dh10a dh11a dh12a dh13a dh14a dh15a dh16a dh17a dh18a dh19a"
adults="dh52a dh53a dh54a dh55a dh56a dh57a dh58a dh59a dh60a dh61a dh62a dh63a dh64a dh65a dh66a dh67a dh68a dh69a dh70a dh71a"

subjects="$kids $adults"
#subjects="dh52a"

export MNE_VERBOSE=1

blocks="1 2"
set -o verbose
for subject in $subjects
do
	for block in $blocks
	do
		thisFIF=${EXPDIR}${subject}/${subject}${block}
		Recode_events_for_ERF_derden.pl ${thisFIF}_mc-enhanced.eve ${thisFIF}_mc-eh-derden.eve
	done
done
