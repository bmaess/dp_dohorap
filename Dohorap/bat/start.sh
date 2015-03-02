export EXPNAME=Dohorap
export SBNAME=dh
export DATDIR=/scr/kuba2/Dohorap/Main/Data/
export BATDIR=${DATDIR}bat/
echo "BATDIR:   " $BATDIR
export BEMDIR=${DATDIR}BEM/
echo "BEMDIR:   " $BEMDIR
export EVEDIR=${DATDIR}MEG_mc/
echo "EVEDIR:   " $EVEDIR
export CFGDIR=${DATDIR}cfg/
echo "CFGDIR:   " $CFGDIR
export CFGVPDIR=${DATDIR}cfg_vp/
echo "CFGVPDIR: " $CFGVPDIR
export RAWDIR=${DATDIR}MEG/
echo "RAWDIR:   " $RAWDIR
export DOCDIR=${DATDIR}doc/
echo "DOCDIR:   " $DOCDIR
export LOCDIR=${DATDIR}Localized_avg/
echo "LOCDIR: " $LOCDIR
export LOCKDIR=${DATDIR}lock/
echo "LOCKDIR: " $LOCKDIR
export MRIDIR=${DATDIR}MRI/
echo "MRIDIR:   " $MRIDIR
export FSLDIR=/usr/lib/fsl/5.0/fsl
echo "FSLDIR:   " $FSLDIR
export EXPDIR=${DATDIR}MEG_mc_hp004_ica_l50/
echo "EXPDIR:   " $EXPDIR
export SUBJECTS_DIR=${DATDIR}MRI/freesurfer/
echo "SUBJECTS_DIR:   " $SUBJECTS_DIR
export HEADDIR=${DATDIR}Headmodel/
echo "HEADDIR:  " ${HEADDIR}

pc=`echo $PATH $BATDIR|perl -ne 'split; if ($_[0] =~ /$_[1]/){ print $_[1] } '`
if [ ! ${pc:=test} = $BATDIR ]
then
   export PATH=$PATH:$BATDIR
   export MATLABPATH=$MATLABPATH
   export PATH=$PATH:/neuro/bin/vue:/neuro/bin/util  # for Neuromag Software
   export PERL5LIB=$PERLLIB:$PERL5LIB
   newgrp neuro
   fi
echo "PATH:   " $PATH

