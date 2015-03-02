from __future__ import division
import mne, os
import numpy as np
from scipy.stats import ttest_rel

def nanArray(dimensions):
	a = np.empty(dimensions)
	a.fill(np.nan)
	return a

def stringify(subjectNumbers):
	return ['dh{:#02d}a'.format(subjectNumber) for subjectNumber in subjectNumbers]

def pickChannels(channelLocation, sensortype):
	channelNames = mne.read_selection(channelLocation)
	channelShortNames = [channelName.replace(' ','') for channelName in channelNames]
	channelIDs = mne.pick_types(raw.info, meg=sensortype.lower(), eeg=False, eog=False, stim=False, exclude='bads', selection=channelShortNames)
	return channelIDs

markers = ['Obj', 'Subj']
groups = ['kids','adults']
basePath = os.environ['DATDIR']
rawFile = basePath + 'MEG_mc/dh53a/block1.fif'
locations = ['frontal','temporal','parietal']
channelNames = ['Left-','Right-']
sensortypes = ['Grad','Mag']
selection = 5001

# Load list of subjects
subjects = [[],[]]
dirEntries = os.listdir(os.environ['EXPDIR'])
for dirEntry in dirEntries:
	if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
		if int(dirEntry[2:4]) > 50:		
			subjects[1].append(dirEntry)
		else:
			subjects[0].append(dirEntry)

# Load clusterTimewindows
clusterTimewindows = {groups[0]: [], groups[1]: []}
maxLetters = 0
for group in groups:
	i = 0
	print group
	for sensortype in sensortypes:
		logfilePath = os.environ['DOCDIR'] + 'MEG-Epochs-Conditions'
		for location in locations:
			for direction in channelNames:
				logfile = open('{}/{}_{}{}_{}.txt'.format(logfilePath, group, direction, location, sensortype.lower()), 'r').read().split('\n')
				for line in logfile:
					lineparts = line.split(' ')
					if len(lineparts) == 8:
						p = float(lineparts[-1])
						if p < 0.05:
							tStart = int(lineparts[1])
							tStop = int(lineparts[3])
							tDiff = tStop - tStart
							tStart += int(round(tDiff*0.125))
							tStop -= int(round(tDiff*0.125))
							clusterTimewindows[group].append([tStart, tStop])
							i += 1
							print tStart, tStop, p*100
	if maxLetters < i:
		maxLetters = i

# Create regular time intervals
intervalTimewindows = []
for n in range(11):
	intervalTimewindows.append([n*100+1000, (n+1)*100+1000])

raw = mne.fiff.Raw(rawFile)
hemispheres = ['lh', 'rh']
# Load the blocks and markers into a subject-specific matrix
for groupID, group in enumerate(groups):
	subjectMean = np.zeros((len(subjects[groupID]), len(markers), len(locations), len(hemispheres), len(sensortypes), len(intervalTimewindows)))
	statPath = basePath + 'MEG_stats/' + group
	if not os.path.isdir(statPath):
		os.makedirs(statPath)
	statFilename = '{}/MEG-ClusterStats.txt'.format(statPath)
	statFile = open(statFilename, 'w')
	intervalStatFilename = '{}/MEG-IntervalStats.txt'.format(statPath)
	intervalStatFile = open(intervalStatFilename, 'w')
	for subjectID, subject in enumerate(subjects[groupID]):
		print subjectID, subject
		for markerID, marker in enumerate(markers):
			# Load evoked activity
			evokedfilename = os.environ['EXPDIR'] + subject + '/' + marker + '_average-ave.fif'
			evokedData = mne.fiff.Evoked(fname=evokedfilename, condition=0, baseline=None, kind='average', verbose=False)
			# Process individual data aspects
			for loc, location in enumerate(locations):
				for hem, hemisphere in enumerate(hemispheres):
					roi = channelNames[hem] + location
					for sens, sensortype in enumerate(sensortypes):
						selectedChannels = pickChannels(roi, sensortype)
						if sensortype == 'Grad':
							markerData = np.sqrt(np.mean(np.power(evokedData.data[selectedChannels, :],2),axis=0))
						elif sensortype == 'Mag':
							markerData =  np.mean(evokedData.data[selectedChannels, :],axis=0)

						# Calculate and write energy levels per condition
						title = 'Comparison in the left frontal cortex in ' + subject
						timescale = evokedData.times
						selectedclusterTimewindows = clusterTimewindows[group]
						for i in range(maxLetters):
							if i < len(selectedclusterTimewindows):
								timewindow = selectedclusterTimewindows[i]
							else:
								timewindow = selectedclusterTimewindows[-1]
							timewindowLetter = chr(65+i)
							sampleData = markerData[timewindow[0]:timewindow[1]]
							conditionMean = np.nanmean(sampleData, axis=0)
							statString = '{c} {g} {t} {l}-{h} {s} {d} \n'.format(c=marker, g=group, t=timewindowLetter, h=hemisphere, l=location, s=sensortype, d=conditionMean)
							statFile.write(statString)

						# Prepare comparisons at systematic intervals
						for t, timewindow in enumerate(intervalTimewindows):
							sampleData = markerData[timewindow[0]:timewindow[1]]
							conditionMean = np.nanmean(sampleData, axis=0)
							subjectMean[subjectID,markerID,loc,hem,sens,t] = conditionMean

	statFile.close()

	# Compare average activity
	statText = 'Conditition difference found in {} from {}-{}, between {}s and {}s: p = {}/{}, t = {}/{}\n'
	bonferroni = len(locations) * len(hemispheres) * len(intervalTimewindows)
	for loc, location in enumerate(locations):
		for hem, hemisphere in enumerate(hemispheres):
			for t, timewindow in enumerate(intervalTimewindows):
				tValue = [0,0]; p = [0,0]
				significant = False
				for sens, sensortype in enumerate(sensortypes):
					objData = np.squeeze(subjectMean[:,0,loc,hem,sens,t])
					subjData = np.squeeze(subjectMean[:,1,loc,hem,sens,t])
					tValue[sens],p[sens] = ttest_rel(objData, subjData)
					p[sens] *= bonferroni
					if p[sens] > 1:
						p[sens] = 1.0
				if p[0] < 0.1 or p[1] < 0.1:
					tStart = timescale[timewindow[0]]
					tStop = timescale[timewindow[1]]
					intervalStatFile.write(statText.format(group,location,hemisphere,tStart,tStop,p[0],p[1],tValue[0],tValue[1]))
	intervalStatFile.write('Comparisons in {}: {}\n'.format(group, bonferroni))
	intervalStatFile.close()

print('Number of clusterTimewindows:')
for group in groups:
	print('{}: {}'.format(group, len(clusterTimewindows[group])))
