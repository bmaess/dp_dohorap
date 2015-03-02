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
datDir = basePath + 'Localized_trials/'
hemispheres = ['lh', 'rh']
metrics = ['normal','pooled']
locations = ['PAC','pSTG','aSTG','pSTS','aSTS','BA45','BA44','BA6v']
filtering = 'filtered'
metricID = 0
metric = metrics[metricID]

# Load list of subjects
subjects = []
dirEntries = os.listdir(datDir)
for dirEntry in dirEntries:
	if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
		subjects.append(dirEntry)
timescale = xfrange(-1.0, 4.0, 0.001)
subjects.sort()

# Create regular time intervals
intervalTimewindows = []
for n in range(10):
	intervalTimewindows.append([n*200+1000, (n+1)*200+1000])

# Load the blocks and markers into a subject-specific matrix
for subjectID, subject in enumerate(subjects):
	condition1 = {}
	condition2 = {}
	for location in locations:
		condition1[location] = {'lh':{}, 'rh':{}}
		condition2[location] = {'lh':{}, 'rh':{}}
	print ('Loading trials from subject {}'.format(subject))
	filesFound = True
	for markerID, marker in enumerate(markers):
		# Load localized activity
		activityFile = datDir + subject + '/' + marker + '_' + metric + '_' + filtering + '-epo.mat'
		if os.path.exists(activityFile):
			markerData = spio.loadmat(activityFile)
			for location in locations:
				for hemisphere in hemispheres:
					dataSet = np.squeeze(np.array(markerData[hemisphere + '_' + location]))
					for t, timewindow in enumerate(intervalTimewindows):
						if marker == markers[0]:
							condition1[location][hemisphere][t] = []
						elif marker == markers[1]:
							condition2[location][hemisphere][t] = []
						for data in dataSet:
							sampleData = np.squeeze(data[timewindow[0]:timewindow[1]])
							averageActivity = np.nanmean(sampleData, axis=0)
							if marker == markers[0]:
								condition1[location][hemisphere][t].append(averageActivity)
							elif marker == markers[1]:
								condition2[location][hemisphere][t].append(averageActivity)
		else:
			print('{} not found! Skipping subject {}...'.format(activityFile, subject))
			filesFound = False

	if filesFound:
		# Open output file
		statPath = basePath + 'MEG_stats/'
		if not os.path.isdir(statPath):
			os.makedirs(statPath)
		intervalStatFilename = '{}/Localized-IntervalStats-{}.txt'.format(statPath, subject)
		intervalStatFile = open(intervalStatFilename, 'w')
		intervalMatFilename = '{}/Localized_IntervalMatlab_{}.m'.format(statPath, subject)
		intervalMatFile = open(intervalMatFilename, 'w')
		intervalMatFile.write('function [t, s] = Localized_IntervalMatlab()\nt = zeros(2,{2});\ns = zeros({0},{1},{2});\n'.format(len(locations),len(hemispheres),len(intervalTimewindows)) )

		# Blindly compare activity in monotonic time windows
		statText = 'Conditition difference found in {}-{}, between {:1.3f}s and {:1.3f}s: p = {:2.2f}%, t({}) = {:1.2f}\n'
		matText = 's({}, {}, {}) = {:1.8f};\n'
		pCorrected = np.zeros((len(hemispheres), len(locations), len(intervalTimewindows)))
		tValues = np.zeros((len(hemispheres), len(locations), len(intervalTimewindows)))
		for hem, hemisphere in enumerate(hemispheres):
			for loc, location in enumerate(locations):
				pValues = []
				for t, timewindow in enumerate(intervalTimewindows):
					objData = np.array(condition1[location][hemisphere][t])
					subjData = np.array(condition2[location][hemisphere][t])
					sampleSize = int(np.round(np.mean([subjData.shape[0], objData.shape[0]])))
					objSample = np.random.choice(objData, sampleSize, True)
					subjSample = np.random.choice(subjData, sampleSize, True)
					n = len(objData);
					tValue,pValue = ttest_rel(objSample, subjSample)
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
					if pValue < .05:
						intervalStatFile.write(statText.format(location,hemisphere,tStart,tStop,pValue*100,n,tValue))
					# write the Matlab syntax
					intervalMatFile.write(matText.format(loc+1, hem+1, t+1, pValue))
			
		intervalStatFile.close()
		intervalMatFile.write('end')
		intervalMatFile.close()
