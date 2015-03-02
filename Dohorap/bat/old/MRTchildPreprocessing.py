import os, tarfile
MRIpath = '/SCR/Dohorap/Main/Data/MRI/'
subjects = os.listdir(MRIpath)

for subject in subjects:
	if subject[0:2] == 'dh' and '.' not in subject:
		subjectpath = MRIpath + subject + '/'
		if os.path.isfile(subjectpath + 'Scans.txt'):
			scanfile = open(subjectpath + 'Scans.txt')
			scans = scanfile.read().split('\n')
			if os.path.isdir(subjectpath + 'DICOM'):
				dicomFiles = os.listdir(subjectpath + 'DICOM')
				if len(dicomFiles) > 0 and len(scans) > 0:
					for scan in scans:
						scanParts = scan.split(' ')
						if len(scanParts) > 1:
							scanID = scanParts[0]
							scanName = scanParts[1]
							scanFiles = []
							tar = tarfile.open(subjectpath + scanName + '.tar.gz', 'w:gz')
							for dicomFile in dicomFiles:
								if dicomFile[0:4] == scanID:
									tar.add(subjectpath + 'DICOM/' + dicomFile)
							tar.close()
