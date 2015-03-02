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

# Create regular time intervals
intervalTimewindows = []
for n in range(8):
	intervalTimewindows.append([n*200+1000, (n+1)*200+1000])

# Load the blocks and markers into a subject-specific matrix, and plot each condition
for groupID, group in enumerate(groups):
	subjectMean = np.zeros((len(subjects[groupID]), len(markers), len(locations), len(hemispheres), len(intervalTimewindows)))
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

			# Prepare comparisons at systematic intervals
			if filesFound:
				for loc, location in enumerate(locations):
					for t, timewindow in enumerate(intervalTimewindows):
						for markerID, marker in enumerate(markers):
							data = np.squeeze(hemisphereData[marker][location])
							sampleData = data[timewindow[0]:timewindow[1]]
							conditionMean = np.nanmean(sampleData, axis=0)
							subjectMean[subjectID,markerID,loc,hem,t] = conditionMean
							

	# Open output file
	statPath = basePath + 'MEG_stats/' + group
	if not os.path.isdir(statPath):
		os.makedirs(statPath)
	intervalStatFilename = '{}/Localized-IntervalStats.txt'.format(statPath)
	intervalStatFile = open(intervalStatFilename, 'w')
	intervalMatFilename = '{}/Localized_IntervalMatlab.m'.format(statPath)
	intervalMatFile = open(intervalMatFilename, 'w')
	intervalMatFile.write('function [t, s] = Localized_IntervalMatlab()\nt = zeros(2,{2});\ns = zeros({0},{1},{2});\n'.format(len(locations),len(hemispheres),len(intervalTimewindows)) )

	# Blindly compare activity in monotonic time windows
	statText = 'Conditition difference found in {}-{}, between {:1.3f}s and {:1.3f}s: p = {:2.2f}%, t({}) = {:1.2f}\n'
	matText = 's({}, {}, {}) = {:1.8f};\n'
	pCorrected = np.zeros((len(hemispheres), len(locations), len(intervalTimewindows)))
	tValues = np.zeros((len(hemispheres), len(locations), len(intervalTimewindows)))
	n = len(group)
	for hem, hemisphere in enumerate(hemispheres):
		for loc, location in enumerate(locations):
			pValues = []
			for t, timewindow in enumerate(intervalTimewindows):
				objData = np.squeeze(subjectMean[:,0,loc,hem,t])
				subjData = np.squeeze(subjectMean[:,1,loc,hem,t])
				n = len(objData);
				tValue,pValue = ttest_rel(objData, subjData)
				pValues.append(pValue)
				tValues[hem, loc, t] = tValue
			pCorrected[hem, loc, :] = stats.p_adjust(FloatVector(pValues), method = 'fdr') # pValues
	for t, timewindow in enumerate(intervalTimewindows):
		tStart = timescale[timewindow[0]]
		tStop = timescale[timewindow[1]]
		intervalStatFile.write('\n')
		intervalMatFile.write('t(:,{}) = [{} {}];\n'.format(t+1, tStart, tStop))
		for loc, location in enumerate(locations):
			for hem, hemisphere in enumerate(hemispheres):
				hemisphere = hemispheres[hem]
				pValue = pCorrected[hem,loc,t]
				tValue = tValues[hem,loc,t]
				# write something human-readable
				if pValue < .08:
					intervalStatFile.write(statText.format(location,hemisphere,tStart,tStop,pValue*100,n,tValue))
				# write the Matlab syntax
				intervalMatFile.write(matText.format(loc+1, hem+1, t+1, pValue))
				
	intervalStatFile.close()
	intervalMatFile.write('end')
	intervalMatFile.close()
