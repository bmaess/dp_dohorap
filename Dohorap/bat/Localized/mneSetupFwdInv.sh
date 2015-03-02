#!/bin/bash
################################################################################
#                                                                              #
# Copyright (C) 2006-2009 by                                                   #
#                                                                              #
# Max-Planck-Institute of Human Cognitive and Brain Sciences                   #
# PO Box 500 355, D-04303 Leipzig, Germany                                     #
#                                                                              #
# EMail maess@cbs.mpg.de                                                       #
# WWW   www.cbs.mpg.de                                                         #
#                                                                              #
# This software may be freely copied, modified, and redistributed provided     #
# that this copyright notice is preserved on all copies.                       #
#                                                                              #
# You may not distribute this software, in whole or in part, as part of any    #
# commercial product without the express consent of the author.                #
#                                                                              #
# There is no warranty or other guarantee of the fitness of this software      #
# for any purpose. It is provided solely "as is".                              #
#                                                                              #
################################################################################
# $Id: mne_setup_fwdinv.sh 2983 2014-04-24 09:25:42Z maess $

USAGE=`cat << EOU

usage : mne_setup_fwdinv.sh measfile mrifile bemfile srcfile megregvalue [covfile]
 
measfile        - data file containing evoked responses, 
                  e.g. pr01a/pr01a__ss_h020_l25_avr.fif 
mrifile         - data file containing the MRI data and the transformation 
                  between MEG and MRI coordinate systems, e.g.
		  fslvol/pr01/mri/T1-neuromag/sets/COR-ma*.fif
bemfile	
		  fslvol/pr01/bem/pr01-5120-bem-sol.fif
srcfile
		  fslvol/pr01/bem/pr01-ico-5p-src.fif		  
megregvalue - regularization parameter between 0 and 1 (determined by the ratio between smallest and largest eigenvalue of the covariance matrix, as described for the variable epsilon_k in the MNE manual 6.2.4)
covfile		  	  

EOU`

if [ $# -lt 5 ] 
then
    echo "$USAGE" 
    exit
fi
if [ ${EXPDIR:-unset} == unset ]
then
   echo "Please run first: \"source bat/start.sh\"";
   exit 1;
   fi

PROGRAM=`basename $0`
COMMANDLINE="$PROGRAM $*"   
export SPACING=5; 
export MEASFILE=$1;     shift;
export MRIFILE=$1;      shift;
export BEMFILE=$1;      shift;
export SRCFILE=$1;      shift;
export MEGREGVALUE=$1;	 shift;
if [ $# -gt 0 ]
then
   export COVFILE=$1;	shift;
else
   TMP1=`dirname ${MEASFILE}`
   TMP2=`basename ${MEASFILE} '.fif'`
   export COVFILE=${TMP1}/${TMP2}-cov.fif
fi

if [ ! -r ${MEASFILE} ] 
then
   echo "E: Cannot read from: ${MEASFILE}"
   echo "E: Aborting."
   exit 1
fi
if [ ! -r ${MRIFILE} ] 
then
   echo "E: Cannot read from: ${MRIFILE}"
   echo "E: Aborting."
   exit 1
fi
if [ ! -r ${SRCFILE} ] 
then
   echo "E: Cannot read from: ${SRCFILE}"
   echo "E: Aborting."
   exit 1
fi
if [ ! -r ${BEMFILE} ] 
then
   echo "E: Cannot read from: ${BEMFILE}"
   echo "E: Aborting."
   exit 1
fi
if [ ! -r ${COVFILE} ] 
then
   echo "E: Cannot read from: ${COVFILE}"
   echo "E: Aborting."
   exit 1
fi

TMP=`dirname $MEASFILE`
export SUBJECT=`basename $TMP`

TMP1=`basename $SRCFILE`
export FSLSUBJECT=`perl -e 'printf "%s",substr($ARGV[0],0,5)' $TMP1`

echo "MEG subject: $SUBJECT"
echo "MRI subject: $FSLSUBJECT"
echo "MEG regularization value: $MEGREGVALUE"

export BEMSTRING=`perl -e 'if ($ARGV[0]=~/\S{4}\-(\d+(\-\d+\-\d+)?)\-bem/) { print $1 }' ${BEMFILE}`
export SRCSTRING=`perl -e 'if ($ARGV[0]=~/\S{4}\-(\S+\-\S+)\-src/) { print $1 }' ${SRCFILE}`
export CORSTRING=`perl -e 'if ($ARGV[0]=~/COR\-(\S+).fif/) { print $1 }' ${MRIFILE}`

MAKEPATH=`dirname $0`
echo "Running: $COMMANDLINE"
make -rf ${MAKEPATH}/mneSetupFwdinvMakefile
