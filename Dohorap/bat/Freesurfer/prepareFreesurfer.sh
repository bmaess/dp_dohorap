#!/bin/bash

subjects="02 03 04 05 06 07 09 10"
StillWaitingForMRIs="dh61a dh70a dh71a"
basepath="/scr/kuba2/Dohorap/Main/Data/MRI"
for s in $subjects; do
	subject="dh${s}a"
	mkdir -p $basepath/freesurfer/$subject/mri/orig
	mkdir -p $basepath/freesurfer/$subject/mri/t2
	mri_convert $basepath/$subject/T1/t1mprsagADNI32Ch.nii $basepath/freesurfer/$subject/mri/orig/001.mgz
	mri_convert $basepath/$subject/T2/rt2spcsagp2iso.nii $basepath/freesurfer/$subject/mri/t2/t2.mgz
done
