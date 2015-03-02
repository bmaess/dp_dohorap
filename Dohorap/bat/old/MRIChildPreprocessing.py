import os, subprocess
MRIpath = '/scr/kuba2/Dohorap/Main/Data/MRI/'
# inputFileNames describe the typical DICOM .tar.gz file names from the MRT lab
inputFileNames = ['t1_mpr_sag_ADNI_32Ch','t2_spc_sag_p6_iso','t2_spc_sag_p2_iso','ep2d_DTI_standard_32Ch_PA','ep2d_DTI_standard_32Ch_AP']
# folderNames defines simple categories for the files above
folderNames = ['T1','T2','T2','DWI','DWI']

def determineContent(filestem):
	validDataset = -1
	for i in xrange(len(inputFileNames)):
		if inputFileNames[i] in filestem or outputFileNames[i] in filestem:
			validDataset = i
	return (validDataset)

if os.access('/usr/lib/fsl/5.0/flirt', os.X_OK):
	 # outputFileNames describe the typical output filenames from dwi2nii; this could change
	outputFileNames = []
	for inputFileName in inputFileNames:
		# simply deletes all underscores
		outputFileNames.append (''.join(inputFileName.split('_')))

	fnull = open(os.devnull, 'w')
	subjects = os.listdir(MRIpath)
	for subject in subjects:
		if subject[0:2] == 'dh' and '.' not in subject:
			print 'Processing subject ' + subject + '...'
			MRIfiles = os.listdir(MRIpath + subject)
			subjectPath = MRIpath + subject + '/'
			if os.path.isfile(subjectPath + 'Scans.txt'): # we have a child dataset, presumably with a single DICOM folder
				scanfile = open(subjectPath + 'Scans.txt')
				print 'Scans.txt found!'
				scans = scanfile.read().split('\n')
				scanNames = dict()
				scanSuccess = dict()
				for scan in scans:
					scanParts = scan.split(' ')
					if len(scanParts) > 1:
						scanNames[scanParts[0]] = scanParts[1]
					scanSuccess[scanParts[0]] = False
				dicomPath = subjectPath + 'DICOM/'
				if os.path.isdir(dicomPath):
					print 'DICOM path found'
					# split the DICOM folder contents into separate folders
					dicomFiles = os.listdir(dicomPath)
					for dicomFile in dicomFiles:
						scanPart = dicomFile[0:4]
						print dicomFile, scanPart
						if scanPart in scanSuccess:
							if not scanSuccess[scanPart]:
								subprocess.call(['mri_convert', dicomPath + dicomFile, subjectPath + scanNames[scanPart] + '.nii'])
								scanSuccess[scanPart] = True

else:
	print 'Please start FSL --version 5.0 first!'
