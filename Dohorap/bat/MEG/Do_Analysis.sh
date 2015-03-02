#!/bin/bash

# ./Do_Analysis.sh
# ----------------
# Process: Movement correction and averaging trigger-dependent MEG data
# Input:
# - raw MEG data (MEG/motionCorrected/dh58a/dh58a1.fif)
# - trigger-related configuration (cfg/mne_dohorap_son.cfg)
# - preprocessing configuration (cfg/mne_process_raw_h00l30.cfg)
# - trigger files (MEG/motionCorrected/dh58a/dh58a1-enhanced.eve)
# Output:
# - head origin position (for maxfilter) ${CFGVPDIR}${subject}_head_origin.txt
# - sensor positions check ($DOCDIR/Sensor_Positions/dh58a.png
# - motion-corrected MEG data (MEG/motionCorrected/dh58a/dh58a1_mc.fif)
# - protocol of head movements ($DOCDIR/maxfilter/dh58a1_mc_plog.png
# - simple sss corrected MEG data (MEG/motionCorrected/dh58a/dh58a1_ss.fif)
# - simple event list (MEG/motionCorrected/dh58a/dh58a1_ss.eve)
# - trigger-dependent averaged MEG data ($EXPDIR/dh58a/dh58a-l12h0.4-average-onset_forward.fif)
# Dependencies: MNE

if [ ${EXPDIR:-unset} == unset ]
then
   echo "Please run first: \"source bat/start.sh\"";
   exit 1;
fi
export MNE_VERBOSE=1
   
kids="dh02a dh03a dh04a dh05a dh06a dh07a dh08a dh09a dh10a dh11a dh12a dh13a dh14a dh15a dh16a dh17a dh18a dh19a"
adults="dh52a dh53a dh54a dh55a dh56a dh57a dh58a dh59a dh60a dh61a dh62a dh63a dh64a dh65a dh66a dh67a dh68a dh69a dh70a dh71a"
subjects="$kids $adults"
subjects="dh02a dh53a"
prefilter=_hp004
filter=_l80
fifType=_mc
blocks="1 2"
#_obj _subj
AVRTYPES="_Obj _Subj _Vis _Feed"
prefix=${fifType}${prefilter}${filter}
gconfigFile=${CFGDIR}mne_process_raw${filter}.cfg
set -o verbose
for subject in $subjects
do
	#neuromag_display_sensorpositions.sh $subject "${blocks}"
	for block in $blocks
	do
		stableFIF=$RAWDIR${subject}/${subject}1
		#neuromag_fitsphere2isotrak.sh $stableFIF.fif ${CFGVPDIR}${subject}_head_origin.txt
		#neuromag_headmovementcorrection.sh $subject $block ${stableFIF}.fif
		#neuromag_check_headmovementcorrection.sh $subject $block _mc  # _mc.log file is usually missing
#		neuromag_sss.sh $subject $block ${stableFIF}.fif _ss          # _ss.fif is no longer needed
#		mne_writeevents.sh $subject $block _ss
		rawFIF=${EXPDIR}${subject}/${subject}${block}${fifType}${prefilter}
		eveFile=${EXPDIR}${subject}/${subject}${block}${fifType}-eh-nocomments.eve
		for at in $AVRTYPES; do
			configFile=${CFGDIR}mne_dohorap${at}.cfg
			filteredFIF=${rawFIF}${filter}${at}_average-raw
			mne_average_raw.sh ${gconfigFile} ${configFile} ${rawFIF}.fif ${eveFile} ${filteredFIF}.fif
			#mne_fif2avr.sh ${filteredFIF}.fif ${filteredFIF} ${CFGDIR}fif2avr_condlabels${at}.cfg ${CFGDIR}eeglabels.cfg
		done
	done
done

# average across blocks
for s in $subjects
do
	for at in $AVRTYPES
	do
		fifDir=${EXPDIR}${s}
		fifFile=${prefix}${at}_average-raw
		avrfif=${fifDir}/${s}${fifFile}
		singleblockfiles=`/bin/ls ${fifDir}/${s}[12]${fifFile}.fif`
		mne_average_avr.sh --modus weighted ${avrfif}.fif $singleblockfiles
		mne_fif2avr.sh ${avrfif}.fif ${avrfif}
	done
done

for at in $AVRTYPES
do

files=
for s in $adults
do
   test=${EXPDIR}${s}/${s}${prefix}${at}.fif
   
   if [ -r $test ]
   then
      files="$files $test"
   fi
done
mne_average_avr.sh --modus plain ${EXPDIR}grand/gadlts${prefix}${at}.fif $files

files=
for s in $kids
do
   test=${EXPDIR}${s}/${s}${prefix}${at}.fif
   if [ -r $test ]
   then
      files="$files $test"
   fi
done
mne_average_avr.sh --modus plain ${EXPDIR}grand/grkids${prefix}${at}.fif $files
done
