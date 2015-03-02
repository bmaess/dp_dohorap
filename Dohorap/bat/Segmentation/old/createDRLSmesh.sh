subjectIDs="52 53 54 55 56 57 58 59 60 62 63 64 65 66 67 68 69"
suffices="drls_cfg3 ml"
meshpath="${BATDIR}/Segmentation"
MRIpath="/scr/kuba2/Dohorap/Main/Data/MRI"
for subjectID in ${subjectIDs}; do
	subject="dh${subjectID}a"
	for suffix in ${suffices}; do
		infile="${MRIpath}/${subject}/Segmented/segmented_${suffix}.nii"
		outfile="${MRIpath}/${subject}/Segmented/mesh_${suffix}.mat"
		python ${meshpath}/make_mesh.py -i ${infile} -o ${outfile}
	done
done
