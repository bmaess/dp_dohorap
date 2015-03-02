from __future__ import division
import mne, os
import pylab as pl
import numpy as np
import rstyle
from mne import fiff

def plotGraph(xData, yData, color, label, ax, plotType):
	pl.plot(xData, yData, color=color, label=label)
	if plotType == 'Power':
		ax.fill_between(xData, 0, yData, color=color, alpha=0.5, linewidth=1.5)

def stringify(subjectIDs):
	return ['dh{:#02d}a'.format(ID) for ID in subjectIDs]

def plotCases(data, subject, caseColors, caseText, graphTitle, meaning, plotType, timewindow):
	pl.clf()
	ax = pl.gca()
	if len(data.shape) > 1:
		for case in range(data.shape[0]):
			plotGraph(timescale, data[case,:], caseColors[case], caseText[case], ax, plotType)
	else:
		plotGraph(timescale, data, caseColors, caseText, ax, plotType)

	if plotType == 'ERP':
		ylims = [-1e-13, 1e-13]
	elif plotType == 'Power':
		ylims = [0, 2e-13]

	if not (subject in groups or subject == ''):
		ylims = [ylim * 1.5 for ylim in ylims]
	pl.plot([0,0],ylims,'g')
	pl.legend(loc=1) #1: upper right, 2: upper left
	pl.title(graphTitle)
	ax.set_xlim(timewindow)
	ax.set_ylim(ylims)
	rstyle.rstyle(ax)
	figPath = os.environ['DOCDIR'] + '/MEG-' + plotType + '-ica/' + subject + '/'
	if not os.path.isdir(figPath):
		os.makedirs(figPath)
	figFilename = figPath + meaning + '.png'
	print figFilename
	pl.savefig(figFilename, dpi=150, overwrite=True)

def loadfif(evokedfilename):
	if os.path.exists(evokedfilename):
		evokedData = mne.fiff.Evoked(fname=evokedfilename, condition=0, baseline=None, kind='average', verbose=False)
		if metric == 'Power':
			return evokedData, np.sqrt(np.mean(evokedData.data[selectedChannels, :] ** 2,axis=0)) # Calculate the power
		elif metric == 'ERP':
			return evokedData, np.mean(evokedData.data[selectedChannels, :],axis=0) # Calculate the average ERP
	else:
		print 'Evoked file not found: ' + evokedfilename

def nanArray(dimensions):
	a = np.empty(dimensions)
	a.fill(np.nan)
	return a

def pickChannels(markerID):
	if markerID in [0,1]:
		channelLocation = hemisphere + '-' + location
	elif markerID == 2:
		channelLocation = hemisphere + '-occipital'
	elif markerID == 3:
		channelLocation = hemisphere + '-temporal'
	elif markerID in [4,5]:
		channelLocation = hemisphere + '-parietal'
	channelNames = mne.read_selection(channelLocation)
	channelShortNames = [channelName.replace(' ','') for channelName in channelNames]
	channelIDs = mne.pick_types(raw.info, meg='mag', eeg=False, eog=False, stim=False, exclude='bads', selection=channelShortNames)
	return channelIDs

markers = ['Obj', 'Subj', 'Vis', 'Feed', 'LeftResp', 'RightResp']
blocks = ['1','2']
groups = ['kids','adults']
locations = ['frontal','temporal']
markerLabels = ['Object-first condition', 'Subject-first condition', 'Picture onset', 'Feedback onset', 'Response with the left hand', 'Response with the right hand']
markerColors = ['r', 'b']
hemispheres = ['Left','Right']
hemisphereColors = ['#8855aa', '#6699aa']
groupColors = ['#887799', '#997700']
evokedPath = os.environ['EXPDIR']
rawFile = os.environ['RAWDIR'] + 'dh53a/dh53a1.fif'
timewindow = [-1.0, 4.0]
largestWindow = 5001
subjectIDs = [range(4,13) + range(14,17), range(52,61) + range(62,70) + range(71,71)]
subjects = [stringify(groupIDs) for groupIDs in subjectIDs]

raw = mne.fiff.Raw(rawFile)

# Load the markers into a subject-specific matrix, and plot each condition
for metric in ['ERP', 'Power']:
	hemisphereData = nanArray((len(subjects), len(hemispheres), len(markers), largestWindow))
	for hemisphereID, hemisphere in enumerate(hemispheres):
		for location in locations:
			locationText = hemisphere + ' ' + location + ' cortex'
			locationData = nanArray((len(subjects), len(markers), largestWindow))
			for groupID, group in enumerate(groups):
				group = groups[groupID]
				groupData = nanArray((len(subjects[groupID]), len(markers), largestWindow))
				for subjectID, subject in enumerate(subjects[groupID]):
					timescales = [[],]*len(markers)
					subjectPath = evokedPath + subject + '/'
					subjectData = nanArray((len(markers), largestWindow))
					for markerID, marker in enumerate(markers):
						selectedChannels = pickChannels(markerID)
						evokedfilename = subjectPath + marker + '_average-ave.fif'
						evokedData, subjectData[markerID, :] = loadfif(evokedfilename)
						timescale = evokedData.times

					# Plot subject-specific data
					groupData[subjectID, :, :] = subjectData
					title = 'Comparison between conditions in the ' + locationText + ' in ' + subject
					meaning = '-'.join([hemisphere, location, metric])
					plotCases(subjectData[0:2,:], subject, markerColors, markerLabels[0:2], title, meaning, metric, timewindow)
					title = 'Response to picture onset in the ' + hemisphere + ' occipital cortex in ' + subject
					meaning = '-'.join([hemisphere, 'occipital', metric])
					plotCases(subjectData[2,:], subject, groupColors[groupID], markerLabels[2], title, meaning, metric, timewindow) #2
					title = 'Response to sound onset in the ' + hemisphere + ' temporal cortex in ' + subject
					meaning = '-'.join([hemisphere, 'temporal', metric])
					plotCases(subjectData[3,:], subject, groupColors[groupID], markerLabels[3], title, meaning, metric, timewindow) #3

				# end subjects
				locationData[groupID, :,:] = np.nanmean(groupData,axis=0)

				# Plot two within-group comparisons
				title = 'Comparison between conditions in the ' + locationText + ' in ' + group
				meaning = '-'.join([hemisphere, group, 'conditions', location, metric])
				plotCases(locationData[groupID,0:2,:], '', markerColors, markerLabels[0:2], title, meaning, metric, timewindow)

				# Store hemisphere/group data for later
				if location == locations[1]:
					hemisphereData[groupID, hemisphereID, :,:] = locationData[groupID,:,:]

			# end groups

			# Plot between-group comparisons
			titles = ['Comparison in the ' + locationText + ' for the Object-First case',
				'Comparison in the ' + locationText + ' for the Subject-First case',
				'Response in the occipital cortex to picture onset',
				'Response in the ' + hemisphere + ' temporal cortex to sound onset']
			for markerID in range(4):
				if markerID == 2:
					meaning = '-'.join([hemisphere, markers[markerID], 'occipital', metric])
				elif markerID == 3:
					meaning = '-'.join([hemisphere, markers[markerID], 'temporal', metric])
				else: 
					meaning = '-'.join([hemisphere, markers[markerID], location, metric])
				data = np.squeeze(locationData[:,markerID,:])
				plotCases(data, '', groupColors, groups, titles[markerID], meaning, metric, timewindow)
		
		# end locations

	# end hemispheres

	# Plot between-hemisphere responses
	datasets = [2,3,4,5]
	tempLocations = ['temporal','occipital','left-parietal','right-parietal']
	titleParts = ['responses to sound onset', ' responses to picture onset', 'response by the left hand', 'response by the right hand']
	for groupID, group in enumerate(groups):
		for datasetID, dataset in enumerate(datasets):
			title = 'Hemisphere comparison during ' + titleParts[datasetID] + ' in ' + group
			meaning = '-'.join(['hemispheres', group, tempLocations[datasetID], metric])
			data = np.squeeze(hemisphereData[groupID, :, dataset, :])
			plotCases(data, '', hemisphereColors, hemispheres, title, meaning, metric, timewindow)
