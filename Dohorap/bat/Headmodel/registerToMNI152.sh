#!/bin/bash

res=1

subject=$1

subjectDir=$SUBJECTS_DIR/$subject

mni152=$SUBJECTS_DIR/MNI152_T1_$res"mm_brain.nii.gz"
outreg=$subjectDir/mri/transforms/reg.mni152.$res"mm.dat"

fslregister --mov $mni152 --s $subject --reg $outreg --dof 12

echo "Register T1 to MNI152"
unregistered=$SUBJECTS_DIR/$subject/mri/orig.mgz
registered=$SUBJECTS_DIR/$subject/mri/mni152.orig.mgz
mri_vol2vol --mov $mni152 --targ $unregistered --reg $outreg --inv --o $registered

raw=$MRIDIR/$subject/Segmented/segmented_drls_1mm_cfg3.nii
unregistered=$MRIDIR/$subject/Segmented/segmented_drls_1mm_cfg3_std.nii.gz
registered=$MRIDIR/$subject/Segmented/segmented_drls_1mm_cfg3_mni152.nii.gz
fslreorient2std $raw $unregistered
mri_vol2vol --mov $mni152 --targ $unregistered --reg $outreg --inv --o $registered

