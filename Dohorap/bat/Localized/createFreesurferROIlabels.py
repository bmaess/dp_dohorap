import os

locDir = os.environ['LOCDIR']
expDir = os.environ['EXPDIR']
subjectsDir = os.environ['SUBJECTS_DIR']
labelFileName = subjectsDir + 'a2009s labels.txt'

# Load labels of interest
labelNames = dict()
labelFile = open(labelFileName,'r').readlines()
for labelLine in labelFile:
	while '\n' in labelLine:
		labelLine = labelLine.replace('\n', '')
	labelParts = labelLine.split(': ')
	labelNames[labelParts[0]] = labelParts[1]

hemispheres = ['lh', 'rh']
labelsDir = subjectsDir + 'dh55a' + '/label/'
for labelName in labelNames:
	ROI = labelNames[labelName]
	for hemisphere in hemispheres:
		ROIfileName = hemisphere + '.' + ROI + '.label'
		freesurferFileName = labelName + '-mod-' + hemisphere + '.label'
		refFile = labelsDir + 'annot2009/' + ROIfileName
		symFile = labelsDir + freesurferFileName
		if not os.path.isfile(refFile):
			print 'Not found: ', refFile
		if not os.path.isfile(symFile):
			print refFile
			print symFile
			os.symlink(refFile, symFile)
