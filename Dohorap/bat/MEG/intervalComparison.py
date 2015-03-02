from __future__ import division
import mne, os
import numpy as np
from scipy.stats import ttest_rel
from scipy import io as spio
from rpy2.robjects.packages import importr
from rpy2.robjects.vectors import FloatVector
stats = importr('stats')

markers = ['Obj', 'Subj']
groupNames = ['kids','adults']
basePath = os.environ['DATDIR']
hemispheres = ['lh', 'rh']
directions = ['Left-','Right-']
locations = ['frontal','temporal','parietal','occipital']
metrics = ['signed','norm']

# Load list of subjects
groups = [[],[]]
dirEntries = os.listdir(os.environ['EXPDIR'])
for dirEntry in dirEntries:
	if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
		if int(dirEntry[2:4]) > 50:		
			groups[1].append(dirEntry)
		else:
			groups[0].append(dirEntry)

# Create regular time intervals
intervalTimewindows = []
for n in range(10):
	intervalTimewindows.append([n*200+1000, (n+1)*200+1000])

# Load the blocks and markers into a subject-specific matrix, and plot each condition
for groupID, subjects in enumerate(groups):
	group = groupNames[groupID]
	subjectMean = np.zeros((len(subjects), len(markers), len(locations), len(hemispheres), len(intervalTimewindows)))
	for subjectID, subject in enumerate(subjects):
		for hem, hemisphere in enumerate(hemispheres):
			hemisphereData = {markers[0]:{}, markers[1]:{}}
			filesFound = True
			for markerID, marker in enumerate(markers):
				# Load average activity
				activityFile = os.environ['EXPDIR'] + subject + '/' + marker + '_average-ave.fif'
				if os.path.exists(activityFile):
					evokedFile = mne.fiff.Evoked(fname=activityFile, condition=0, baseline=None, kind='average', verbose=False)
					for location in locations:
						channelLocation = directions[hem] + location
						channelNames = mne.read_selection(channelLocation)
						channelShortNames = [channelName.replace(' ','') for channelName in channelNames]
						selectedChannels = mne.pick_types(evokedFile.info, meg='mag', eeg=False, eog=False, stim=False, exclude='bads', selection=channelShortNames)
						data = np.mean(evokedFile.data[selectedChannels,:],axis=0)
						hemisphereData[marker][location] = data
				else:
					print('File not found: {}'.format(activityFile))
					filesFound = False

			if filesFound:
				for loc, location in enumerate(locations):
					# Prepare comparisons at systematic intervals
					for t, timewindow in enumerate(intervalTimewindows):
						for markerID, marker in enumerate(markers):
							data = np.squeeze(hemisphereData[marker][location])
							sampleData = data[timewindow[0]:timewindow[1]]
							conditionMean = np.nanmean(sampleData, axis=0)
							subjectMean[subjectID,markerID,loc,hem,t] = conditionMean

	# Blindly compare activity in monotonic time windows
	timescale = evokedFile.times
	statPath = basePath + 'MEG_stats/' + group
	intervalStatFilename = '{}/MEG-IntervalStats.txt'.format(statPath)
	intervalStatFile = open(intervalStatFilename, 'w')
	statText = 'Conditition difference in {}-{}, between {:1.3f}s and {:1.3f}s: p = {:2.1f}%, t({}) = {:1.2f}\n'
	pCorrected = np.zeros((len(hemispheres), len(locations), len(intervalTimewindows)))
	tValues = np.zeros((len(hemispheres), len(locations), len(intervalTimewindows)))
	n = len(subjects)
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
		intervalStatFile.write('\n')
		for loc, location in enumerate(locations):
			for hem, hemisphere in enumerate(hemispheres):
				hemisphere = hemispheres[hem]
				tStart = timescale[timewindow[0]]
				tStop = timescale[timewindow[1]]
				pValue = pCorrected[hem,loc,t]
				tValue = tValues[hem,loc,t]
				if pValue < .05:
					intervalStatFile.write(statText.format(location,hemisphere,tStart,tStop,pValue*100,n,tValue))
	intervalStatFile.close()
