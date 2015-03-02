import mne
import os
import scipy.io as spio
import numpy as np
from mne import fiff

def cleanName(name):
	artifacts = ['lh','.','-']
	for artifact in artifacts:	
		if artifact in name:
			name = name.replace(artifact,'')
	return name

def nans(shape, dtype=float):
    a = np.empty(shape, dtype)
    a.fill(np.nan)
    return a

expDir = os.environ['EXPDIR']
docDir = os.environ['DOCDIR']
labelsDir = os.environ['SUBJECTS_DIR'] + 'dh53a' + '/label'

subjects = [[8,11,12,14,15,16],[52,53,54,55,57,58,59,60,62,63,64,65,66,67,68,69]]
ROIs = ['aSTG-lh', 'pSTG-lh', 'Opercular-lh', 'PAC-lh', 'parsorbitalis-lh', 'lh.BA44', 'lh.BA45']
inverseMethod = 'MNE'

matlabDict = {}
objectFirstData = [[],[]]
subjectFirstData = [[],[]]
matlabDict['ROIs'] = ROIs
matlabDict['subjects'] = subjects
for g in [0,1]:
	objectFirstData[g] = [[]]*len(subjects[g])
	subjectFirstData[g] = [[]]*len(subjects[g])
	s = 0
	for subject in subjects[g]:
		subjectID = 'dh{:02d}a'.format(subject)
		# Load epochs
		fifFile = fiff.Raw(expDir + subjectID + '/mc-decision-rejectedEpochs.fif')
		eveFile = mne.read_events(expDir + subjectID + '/mc-decision-rejectedEpochs.eve')
		activityFile = expDir + subjectID + '/' + 'LocalizedTrials.mat'
		subjectData = spio.loadmat(activityFile)
		testData = subjectData[cleanName(ROIs[0])]
		trialLengths = [len(r[0][0]) for r in testData]
		dataSize = [len(ROIs), 304, max(trialLengths)]
		objectFirstTrials = nans(dataSize)
		subjectFirstTrials = nans(dataSize)
		for roi in ROIs:
			objectIndex = 0
			subjectIndex = 0
			roiData = subjectData[cleanName(roi)]
			roiIndex = ROIs.index(roi)
			oStartPoint = 0
			sStartPoint = 0
			for trial in xrange(len(roiData)):
				trialData = roiData[trial][0][0]
				condition = str(eveFile[trial,2])
				t = trialLengths[trial]
				if condition[1] == '1':
					objectFirstTrials[roiIndex, objectIndex, xrange(t)] = trialData
					objectIndex +=1
				elif condition[1] == '2':
					subjectFirstTrials[roiIndex, subjectIndex, xrange(t)] = trialData
					subjectIndex += 1
		objectFirstData[g][s] = objectFirstTrials
		subjectFirstData[g][s] = subjectFirstTrials
		s += 1
		
# unfinished
