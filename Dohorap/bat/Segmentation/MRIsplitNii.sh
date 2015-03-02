subjects="01 08 11 12 14 15 16"
suffices="AP PA"
for subject in ${subjects}; do
	for suffix in ${suffices}; do
		mkdir dh${subject}a/DWI/${suffix}
		fslsplit dh${subject}a/DWI/ep2dDTIstandard32Ch${suffix}.nii dh${subject}a/DWI/${suffix}/
		find dh${subject}a/DWI -name *.nii.gz -exec gunzip -f {} \;
	done
done

