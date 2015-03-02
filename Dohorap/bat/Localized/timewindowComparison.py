from __future__ import division
import mne, os
import numpy as np
from scipy.stats import ttest_rel
from scipy import io as spio
from rpy2.robjects.packages import importr
from rpy2.robjects.vectors import FloatVector
from xfrange import xfrange
stats = importr('stats')

markers = ['Obj', 'Subj']
groups = ['kids','adults']
basePath = os.environ['DATDIR']
hemispheres = ['lh', 'rh']
metrics = ['signed','norm']
channelNames = ['Left-','Right-']
locations = ['PAC','pSTG','aSTG','pSTS', 'aSTS', 'BA45','BA44','BA6v']

# Load list of subjects
subjects = [[],[]]
dirEntries = os.listdir(os.environ['LOCDIR'])
for dirEntry in dirEntries:
	if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
		if int(dirEntry[2:4]) > 50:		
			subjects[1].append(dirEntry)
		else:
			subjects[0].append(dirEntry)
timescale = xfrange(-1.0, 4.0, 0.001)

# Load clusterTimewindows
MEGlocations = ['frontal','temporal','parietal']
sensortypes = ['Grad','Mag']
clusterTimewindows = {groups[0]: [], groups[1]: []}
maxLetters = 0
for group in groups:
	i = 0
	print group
	for sensortype in sensortypes:
		logfilePath = os.environ['DOCDIR'] + 'MEG-Epochs-Conditions'
		for location in MEGlocations:
			for direction in channelNames:
				logfile = open('{}/{}_{}{}_{}.txt'.format(logfilePath, group, direction, location, sensortype.lower()), 'r').read().split('\n')
				for line in logfile:
					lineparts = line.split(' ')
					if len(lineparts) == 8:
						p = float(lineparts[-1])
						if p < 0.1:
							# Cluster analysis data starts at -500ms!
							tStart = int(lineparts[1])+500
							tStop = int(lineparts[3])+500
							tDiff = tStop - tStart
							tStart += int(round(tDiff*0.125))
							tStop -= int(round(tDiff*0.125))
							clusterTimewindows[group].append([tStart, tStop])
							i += 1
							print tStart, tStop, p*100, direction, location, sensortype
	if maxLetters < i:
		maxLetters = i

# Load the blocks and markers into a subject-specific matrix, and plot each condition
for groupID, group in enumerate(groups):
	subjectMean = np.zeros((len(subjects[groupID]), len(markers), len(locations), len(hemispheres), len(metrics), len(intervalTimewindows)))
	# Open output file
	statPath = basePath + 'MEG_stats/' + group
	statFilename = statPath + '/Localized-ClusterStats.txt'
	timewindowFilename = statPath + '/Localized-Timewindows.txt'
	if not os.path.isdir(statPath):
		os.makedirs(statPath)
	statFile = open(statFilename, 'w')
	timewindowFile = open(timewindowFilename, 'w')
	metricID = 0
	metric = metrics[metricID]
	for subjectID, subject in enumerate(subjects[groupID]):
		for hem, hemisphere in enumerate(hemispheres):
			hemisphereData = {markers[0]:{}, markers[1]:{}}
			filesFound = True
			for markerID, marker in enumerate(markers):
				# Load localized activity
				activityFile = basePath + '/Localized_avg/' + subject + '/' + marker + '_' + metric + '-' + hemisphere + '.mat'
				if os.path.exists(activityFile):
					markerData = spio.loadmat(activityFile)
					for location in locations:
						data = np.squeeze(np.array(markerData[location]))
						hemisphereData[marker][location] = data
				else:
					print('File not found: {}'.format(activityFile))
					filesFound = False

			if filesFound:
				selectedTimewindows = clusterTimewindows[group]
				for loc, location in enumerate(locations):
					for i in range(maxLetters):
						if i < len(selectedTimewindows):
							timewindow = selectedTimewindows[i]
						else:
							timewindow = selectedTimewindows[-1]
						timewindowLetter = chr(65+i)
						timewindowFile.write('Timewindow {} for {}-{}: {} to {}s\n'.format(timewindowLetter, location, hemisphere, timescale[timewindow[0]], timescale[timewindow[1]]))
						for marker in markers:
							# Calculate average activity in each timewindow
							data = np.squeeze(hemisphereData[marker][location])
							sampleData = data[timewindow[0]:timewindow[1]]
							conditionMean = np.nanmean(sampleData, axis=0)
							statString = '{c} {g} {t} {l}-{h} {d} \n'.format(c=marker, g=group, t=timewindowLetter, h=hemisphere, l=location, d=conditionMean)
							statFile.write(statString)

					# Prepare comparisons at systematic intervals
					for t, timewindow in enumerate(intervalTimewindows):
						for markerID, marker in enumerate(markers):
							data = np.squeeze(hemisphereData[marker][location])
							sampleData = data[timewindow[0]:timewindow[1]]
							conditionMean = np.nanmean(sampleData, axis=0)
							subjectMean[subjectID,markerID,loc,hem,metricID,t] = conditionMean
							
	statFile.close()
