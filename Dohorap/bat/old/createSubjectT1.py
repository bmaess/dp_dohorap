from subprocess import call
from os import mkdir, listdir, getcwd, environ
import operator

t1labels = ['t1','mpr','sag','adni','ADNI','32ch','.tar.gz']
weights = [100, 5, 10, 20, 20, 50, 500]
maxThreads = 3
batDir = getcwd().split('/')
rootDir = '/'.join(batDir[0:-1])
if environ['SUBJECTS_DIR'] != rootDir + '/freesurfer':
	raise NameError('enter first: export SUBJECTS_DIR=' + rootDir + '/freesurfer')
subjectDirs = listdir(rootDir + '/MRI')

outfile = open('subjectT1.csv','w')
for subjectDir in subjectDirs:
	if subjectDir[0:2] == 'dh':
		fullSubjectDir = rootDir + '/MRI/' + subjectDir
		dataDir = listdir(fullSubjectDir)
		dataFiles = []
		scores = []
		if len(dataDir) > 0:
			for dataFile in dataDir:
				score = 0
				for i in xrange(len(t1labels)):
					if t1labels[i] in dataFile:
						score += weights[i]
					else:
						score -= weights[i]
				dataFiles.append(dataFile)
				scores.append(score)
			bestFile = dataFiles[max(xrange(len(scores)), key=scores.__getitem__)]
			if max(scores) > 0:
				outfile.write(subjectDir + ',' + bestFile + '\n')

