# usage: assembleVistaMesh <subject>
# requires start.sh, FSL and MNE (in this order)

subject=$1
s=${MRIDIR}dh${subject}a/Segmented
h=${HEADDIR}dh${subject}a

cd $s

# combine the different segmentation probability maps
MRI=t1mprsagADNI32Ch.nii
fslmerge -a ${s}/c${MRI}.gz ${s}/c1${MRI} ${s}/c2${MRI} ${s}/c3${MRI} ${s}/c4${MRI} ${s}/c5${MRI} ${s}/c6${MRI}
python ${BATDIR}Segmentation/mask.py --input ${s}/c${MRI}.gz --output ${s}/segmentation.nii

# clean the segmentations
python ${BATDIR}Segmentation/clean.py --input ${s}/segmentation.nii --output ${s}/segmentation_clean.nii

# thicken the grey matter
python ${BATDIR}Segmentation/thicken_grey.py -i ${s}/segmentation_clean.nii -o ${s}/segmentation_clean_venant.nii


cd ${h}

# convert voxel image to hexagonal mesh
python ${BATDIR}Headmodel/make_mesh.py -i ${s}/segmentation_clean_venant.nii -o ${h}/mesh.mat -s dh${subject}a

# put one dipole into each cortical voxel
python ${BATDIR}Headmodel/make_sourcespace.py -m ${h}/mesh.mat -s ${s}/segmentation_clean_venant.nii -o ${h}/sourcespace.mat -i dh${subject}a

# save the material label for each vertex
python ${BATDIR}Headmodel/write_label.py -i ${s}/segmentation_clean_venant.nii -o ${h}/label.mat

# combine mesh.mat and label.mat into the Vista-formatted head.v
python ${BATDIR}Headmodel/write_vistamesh.py

cd ${DATDIR}
