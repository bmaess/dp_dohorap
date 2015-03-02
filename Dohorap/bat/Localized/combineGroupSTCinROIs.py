# requires about 60 seconds to run

import mne
import os
import numpy as np
import scipy.io as spio

locDir = os.environ['DATDIR'] + 'Localized_avg/'
expDir = os.environ['EXPDIR']
subjectsDir = os.environ['SUBJECTS_DIR']
labelsDir = subjectsDir + 'dh55a' + '/label/Dohorap/'
hemispheres = ['lh','rh']
labelFileName = subjectsDir + 'a2009s labels.txt'
inverseMethod = 'sLORETA'
conditions = ['Obj','Subj','Vis','Feed']
groups = ['kids', 'adults']
dataLength=5001
metrics = ['norm','signed']

# Load labels of interest
labelNames = dict()
labelFile = open(labelFileName,'r').readlines()
for labelLine in labelFile:
	while '\n' in labelLine:
		labelLine = labelLine.replace('\n', '')
	labelParts = labelLine.split(': ')
	labelNames[labelParts[0]] = labelParts[1]

for metric in metrics:
	for groupID, group in enumerate(groups):
		for hemisphere in hemispheres:
			for conditionID, condition in enumerate(conditions):
				matlabDict = {}
				activityFile = locDir + metric + '-' + group + '-' + condition + '-' + hemisphere + '-' + 'localized.mat' 
				stcFile = locDir + metric + '-' + group + '-' + condition + '-' + hemisphere + '.stc'
				if os.path.exists(stcFile):
					print stcFile
					sourceActivity = mne.read_source_estimate(stcFile)
					for labelName in labelNames:
						roi = hemisphere + '.' + labelNames[labelName]
						label = mne.read_label(labelsDir + roi + '.label')
						# Select only the labeled activity
						roiActivity = sourceActivity.in_label(label)
						matlabDict[labelName] = np.mean(roiActivity.data, axis=0)
						if metric == 'norm':
							strength = np.mean(matlabDict[labelName])
						elif metric == 'signed':
							strength = np.std(matlabDict[labelName])
						print hemisphere, labelName, strength
					spio.savemat(activityFile, matlabDict, do_compression=True)
				else:
					print 'Not found: ' + stcFile
