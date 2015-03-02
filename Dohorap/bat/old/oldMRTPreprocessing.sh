# required:
# - t1 data in folder "t1_mpr_sag_ADNI_32Ch"
# - t2 data in folder "t2_spc_sag_p6_iso"
# - dwi data in folder "ep2d_DTI_standard_32Ch"
# - dwi-PA data in folder "ep2d_DTI_standard_32Ch_PA"
t1="t1_mpr_sag_ADNI_32Ch"
t2="t2_spc_sag_p6_iso"
dwi="ep2d_DTI_standard_32Ch"
dwiPA="ep2d_DTI_standard_32ch_PA"

# Test for FSL (required for coregistration and diffusion correction)
command -v flirt >/dev/null 2>&1 || { echo >&2 "flirt not found. Please run FSL --version 5.0 first."; exit 1; }
# Check for the two data folders
if test -d ./$t1; then
	if test -d ./$t2; then
		# create DICOMDIR
		/a/sw/misc/linux/diffusion/prep_ima_data.sh $t1
		/a/sw/misc/linux/diffusion/prep_ima_data.sh $t2
		# convert DICOM to Vista
		/a/sw/misc/linux/diffusion/dictov $t1/DICOMDIR t1old.v
		# rotate file into correct orientation
		/a/sw/misc/linux/diffusion/visotrop t1old.v t1raw.v
		rm -f t1old.v
		# align to Talairach coordinates
		/a/sw/misc/linux/diffusion/vcacp -in t1raw.v -template /a/sw/misc/linux/diffusion/bruker.v -out t1_talairach.v -report cacp.txt
		rm -f t1_talairach.v
		# save the result, with and without skull
		/a/sw/misc/linux/diffusion/vtal -in t1raw.v -out t1_peeled.v `more cacp.txt` -size huge
		/a/sw/misc/linux/diffusion/vtal -in t1raw.v -out t1.v `more cacp.txt` -size huge -type 1
		rm -f t1raw.v cacp.txt
		/a/sw/misc/linux/diffusion/vimage2nifti t1.v t1.nii.gz

		# map to T2 image:
		/a/sw/misc/linux/diffusion/dictov $t2/DICOMDIR t2old.v
		# correct the orientation
		/a/sw/misc/linux/diffusion/vtranspose3d -xy zxy t2old.v t2_rotated.v
		rm -f t2old.v
		# Coregister t1 and t2 data (requires flirt)
		/a/sw/misc/linux/diffusion/vdreg t2_rotated.v -ref t1_peeled.v -cost mutualinformation trans.v
		/a/sw/misc/linux/diffusion/vdapplyreg t2_rotated.v -ref t1.v -trans trans.v t2.v
		rm -f t2_rotated.v trans.v	t1_peeled.v t1.v
		/a/sw/misc/linux/diffusion/vimage2nifti t2.v t2.nii.gz
		rm -f t2.v
	else
		echo "$t2 doesn't exist! Skipping anatomical preprocessing"
	fi
else
	echo "$t1 doesn't exist! Skipping anatomical preprocessing"
fi

if test -d ./$dwi; then
	if test -d ./$dwiPA; then
		# create DICOMDIR
		cd $dwi; dcmmkdir [0-9]*
		cd ../$dwiPA; dcmmkdir [0-9]*; cd ..
		# convert DICOM to Vista
		/a/sw/misc/bin/diffusion/dictov -in $dwi/DICOMDIR -scans 1 -precision original -out dwi_or.v
		/a/sw/misc/bin/diffusion/dictov -in $dwiPA/DICOMDIR -scans 1 -precision original -out dwiPA_or.v
		/a/sw/misc/bin/diffusion/vimage2nifti dwi_or.v dwi_or.nii
		/a/sw/misc/bin/diffusion/vimage2nifti dwiPA_or.v dwiPA_or.nii
		# Extract b0 images from dwi
		b0=(0 11 22 33 44 55 66)
		i=0; j=0
		while [ $i -le 66 ]; do
			if [ $i -eq ${b0[$j]} ]; then
				fslroi dwi_or dwi_b0_$i $i 1
				(( j++ )); fi
			(( i++ )); done
		# Merge b0 images
		fslmerge -t dwi_b0 dwiPA_or dwi_b0_0 dwi_b0_11 dwi_b0_22 dwi_b0_33 dwi_b0_44 dwi_b0_55 dwi_b0_66 
		# Write acquisition directions to acq.txt
		echo "0 -1 0 0.1" > acq.txt
		echo "0 -1 0 0.1" >> acq.txt
		i=1
		while [ $i -le 7 ]; do
			echo "0 1 0 0.1" >> acq.txt
			(( i++ )); done;
		# Resonance correction with inverted pulse (this doesn't actually work yet)
		# topup --imain=dwi_b0 --datain=acq.txt --config=config/topup.cnf --out=dwi_corrected
		# rm -f acq.txt dwi_b0_*
		
	else
		echo "$dwiPA doesn't exist! Skipping DWI preprocessing"
	fi
else
	echo "$dwi doesn't exist! Skipping DWI preprocessing"
fi
