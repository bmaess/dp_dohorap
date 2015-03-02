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
			print '\nProcessing subject ' + subject + '...'
			MRIfiles = os.listdir(MRIpath + subject)
			subjectPath = MRIpath + subject + '/'
			# figure out which type of dataset we're working with
			for MRIfile in MRIfiles:
				os.chdir(subjectPath)
				validDataset = -1
				filename = MRIfile.split('.')
				if len(filename) == 4: # an adult dataset
					filestem = filename[0] + '.' + filename[1]
					if filename[2] == 'tar' and filename[3] == 'gz':
						validDataset = determineContent(filestem)
				elif len(filename) == 3: # a child dataset
					filestem = filename[0]
					if filename[1] == 'tar' and filename[2] == 'gz':
						validDataset = determineContent(filestem)
				elif len(filename) == 2: # any nifti
					filestem = filename[0]
					if filename[1] == 'nii':
						validDataset = determineContent(filestem)
				print MRIfile, validDataset
				if validDataset != -1:
					deepPath = subjectPath + folderNames[validDataset] + '/'
					NIIfile = outputFileNames[validDataset]

					if not os.path.isfile(deepPath + outputFileNames[validDataset] + '.nii'): # we don't have SORTED nifti files
						print 'No sorted Nifti files detected'
						if not os.path.isfile(subjectPath + outputFileNames[validDataset] + '.nii'): # we don't have any nifti files at all, so we should generate them							
							print 'No Nifti files detected at all'
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
									# split the DICOM folder contents into separate folders
									dicomFiles = os.listdir(dicomPath)
									for dicomFile in dicomFiles:
										scanPart = dicomFile[0:4]
										if scanPart in scanSuccess:
											if not scanSuccess[scanPart]:
												if not os.path.isfile(subjectPath + scanNames[scanPart] + '.nii'):
													subprocess.call(['mri_convert', dicomPath + dicomFile, subjectPath + scanNames[scanPart] + '.nii'])
							else:
								# Extract the DICOM tarball to a subfolder
								subprocess.call(['tar', 'xfvz', MRIfile], stdout=fnull)
						if os.path.isfile(subjectPath + outputFileNames[validDataset] + '.nii'): # we have unsorted nifti files, so let's sort them
							# rotate labels to standard convention
							subprocess.call(['fslreorient2std', NIIfile + '.nii'], stdout = fnull) # this will fail if FSL isn't running
							# generate the subdirectory if it doesn't exist yet 
							if not os.path.isdir(deepPath):
								os.makedirs(deepPath)
							# sort dataset into correct folder
							subprocess.call(['mv', NIIfile + '.nii', deepPath])
							if validDataset >= 3: # if it's a DWI, move the non-nifti files too
								subprocess.call(['mv', NIIfile + '.bval', deepPath])
								subprocess.call(['mv', NIIfile + '.bvec', deepPath])
						
					if os.path.isfile(deepPath + outputFileNames[validDataset] + '.nii'): # we have sorted nifti files, so we may be finished if it isn't a DWI
						print 'Sorted Nifti files found!'
						os.chdir(deepPath)
						finished = 0
						if not folderNames[validDataset] == 'DWI': # it's not a DWI, so we're finished!
							finished = 1
						else: # it's a DWI, so we have to check the output files
							dwiCategory = NIIfile[-2:]
							dwiPath = deepPath + dwiCategory
							if not os.path.isfile(dwiPath + '/0001.nii.gz'): # there probably aren't any temporary files left
								if os.path.isfile(dwiPath + '/0001.nii'): # and we have correct output files - so we're finished!
									finished = 1
						if not finished:
							# extract 4D nifti file bundles into the respective phase subdirectory (usually 'AP' or 'PA)
							if not os.path.isdir(dwiPath):
								os.makedirs(dwiPath)
							subprocess.call(['fslsplit', NIIfile + '.nii', dwiCategory + '/'])

							# unzip the packed 3D nifti files (unfortunately, something that fslsplit doesn't support)
							# this may become obsolete if the ACID toolbox from SPM starts supporting .nii.gz files
							os.chdir(dwiPath)
							dwiFiles = os.listdir(dwiPath)
							for dwiFile in dwiFiles:
								if dwiFile[-2:] == 'gz':
									subprocess.call(['gunzip', '-f', dwiFile])
								else:
									print 'Error: dcm2nii didn\'t generate the filename that was predicted in the variable outputFileNames. Please update accordingly.'

				else:
					if '.tar.gz' in MRIfile:
						print 'Not a valid dataset: ' + subject + '/' + MRIfile
else:
	print 'Please start FSL --version 5.0 first!'
