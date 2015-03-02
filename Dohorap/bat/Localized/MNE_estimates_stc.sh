#!/bin/bash
# $Id: MNE_estimates_stc.sh 2911 2014-02-18 16:37:47Z maess $

# set 1
sets="1"
EXPDIR=/scr/kuba2/Dohorap/Main/Data/MEG/motionCorrected/

CONDS="onset_forward onset_reverse decision_forward decision_reverse"
subjects="02 03 04 05 06 07 08 09 10 11 12 14 15 16 52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"

export morphsubj=dh58a
method=sLORETA

FILTER="l12h0.4"

#export STCTYPE=signed
export STCTYPE=unsigned

OUTDIR=${EXPDIR}subject_estimates_${method}_${morphsubj}_${STCTYPE}
if [ ! -d $OUTDIR ]
then
   mkdir -p $OUTDIR
   fi

#for filter in $FILTER
#do
filter=$FILTER

CONDITION=avr
MAKECFG=${CFGDIR}mne_subject_estimates_stc_Makefile_${CONDITION}.cfg

for s in $subjects
do
st=1
for c in $CONDS
do
make -drf ${BATDIR}mne_subject_estimates_stc_Makefile INV=${EXPDIR}${s}/${s}__-5120-ico-5p-${s}-aligned-inv.fif MEAS=${EXPDIR}${s}/${s}-${filter}-average-${c}.fif SET=${st} S=${s} MORPH=${morphsubj} METHOD=${method} MAKECFG=${MAKECFG} OUT=${OUTDIR}/${s}_${filter}_avr-ico-5p-${c}-lh.stc 
done
done
#done


# average all single subject solutions into a grand average solution
# morphing to a specific subject was done in the previous step

export INDIR=${OUTDIR}

#for filter in $FILTER
#do

#export EXPNAME=Dohorap
for c in $CONDS
do
#st=1
CFG=${CFGDIR}${EXPNAME}_${method}_${morphsubj}_${c}-lh.tempcfg
DEST=${EXPDIR}grandaverage_estimates_${method}_${morphsubj}_${STCTYPE}/${EXPNAME}_${method}_${morphsubj}_${c}-lh.stc

export DSTDIR=`dirname $DEST`
if [ ! -d $DSTDIR ]
then
   mkdir -p $DSTDIR
   fi

# collect all existing files for grand averaging
INFILES=
for s in $subjects
do
currentLeft=`/bin/ls ${INDIR}/${s}_${filter}_avr-ico-5p-${c}-lh.stc 2>/dev/null`
currentRight=`/bin/ls ${INDIR}/${s}_${filter}_avr-ico-5p-${c}-rh.stc 2>/dev/null`
INFILES="${currentLeft} ${currentRight} ${INFILES}"
done

TEMPFILES=$INFILES

INFILES=
for I in $TEMPFILES
do
   pt=`dirname $I`;
   bt=`basename $I`;
   cd $pt
   stl=`perl -e '$t=$ARGV[0];$t=~/.*(dh..a).*ico-5p-(.*)-lh.stc/; printf "%s_%s-lh.stc",$1,$2;' $I`; 
   str=`perl -e '$t=$ARGV[0];$t=~/.*(dh..a).*ico-5p-(.*)-rh.stc/; printf "%s_%s-rh.stc",$1,$2;' $I`;
   st=ERROR
   if [[ $str == *$c-rh.stc* ]]; then st=${str}; fi
   if [[ $stl == *$c-lh.stc* ]]; then st=${stl}; INFILES="${st} ${INFILES}"; fi
   rm -f ${st}
   ln -s ${bt} ${st};
   cd -
done

make -drf ${BATDIR}mne_grandaverage_estimates_Makefile CFG=${CFG} IN="${INFILES}"  DEST=${DEST}
done
#done

