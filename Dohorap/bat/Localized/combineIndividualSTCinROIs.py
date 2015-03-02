# requires about 60 seconds to run

import mne
import os
import numpy as np
import scipy.io as spio

def nanArray(dimensions):
	a = np.empty(dimensions)
	a.fill(np.nan)
	return a

def cleanName(name):
	artifacts = ['lh','rh','.','-']
	for artifact in artifacts:
		if artifact in name:
			name = name.replace(artifact,'')
	return name
	
locDir = os.environ['DATDIR'] + 'Localized_avg/'
expDir = os.environ['EXPDIR']
subjectsDir = os.environ['SUBJECTS_DIR']
labelsDir = subjectsDir + 'dh55a' + '/label/Dohorap/'
hemispheres = ['lh','rh']
labelFileName = subjectsDir + 'a2009s labels.txt'
conditions = ['Obj','Subj','Vis','Feed']
dataLength=4001

# Load labels of interest
labelNames = dict()
labelFile = open(labelFileName,'r').readlines()
for labelLine in labelFile:
	while '\n' in labelLine:
		labelLine = labelLine.replace('\n', '')
	labelParts = labelLine.split(': ')
	labelNames[labelParts[0]] = labelParts[1]

# Determine individual subject folders
subjects = []
dirEntries = os.listdir(locDir)
for dirEntry in dirEntries:
	if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
		subjects.append(dirEntry)
subjects.sort()

for metric in ['signed','norm']:
	for subject in subjects:
		for hemisphere in hemispheres:
			for conditionID, condition in enumerate(conditions):
				stcFile = locDir + subject + '/' + condition + '_' + metric + '-' + hemisphere + '.stc'
				matlabDict = {}
				activityFile = locDir + subject + '/' + condition + '_' + metric + '-' + hemisphere + '.mat'
				if os.path.exists(stcFile):
					print stcFile
					sourceActivity = mne.read_source_estimate(stcFile)
					for labelName in labelNames:
						roi = hemisphere + '.' + labelNames[labelName] 
						label = mne.read_label(labelsDir + roi + '.label')
						# Select only the labeled activity
						roiActivity = sourceActivity.in_label(label)
						matlabDict[labelName] = np.mean(roiActivity.data, axis=0)
					spio.savemat(activityFile, matlabDict, do_compression=True)
