basepath="/scr/kuba1/Dohorap/Main/Data/MRI"
tissues="1 2 3 4 5"
subjectIDs="52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"
suffices="drls_1mm_cfg3 drls_1mm_cfg3-ML"

echo "subject approach tissue tissueVolume" > segmentationVolumes.txt
for subjectID in ${subjectIDs}; do
	for suffix in ${suffices}; do
		for tissue in ${tissues}; do
			subject="dh${subjectID}a"
			segmentfile="${basepath}/${subject}/Segmented/segmented_${suffix}.nii"
			# Calculate the volume per tissue
			tissueMin=$(echo "${tissue}-0.1" | bc -l)
			tissueMax=$(echo "${tissue}+0.1" | bc -l)
			volumeDiff=$(fslstats ${segmentfile} -l ${tissueMin} -u ${tissueMax} -v)
			echo ${volumeDiff}
			volumeDiffs=(${volumeDiff// / })
			volumeDiff=${volumeDiffs[1]}
			echo "${subject} ${suffix} ${tissue} ${volumeDiff}" >> segmentationVolumes.txt
		done
	done
done
