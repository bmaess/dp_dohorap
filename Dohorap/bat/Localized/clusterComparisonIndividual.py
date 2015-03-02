"""
=======================================================
Permutation F-test on sensor data with 1D cluster level
=======================================================

One tests if the evoked response is significantly different
between conditions. Multiple comparison problem is addressed
with cluster level permutation test.

"""

# Authors: Alexandre Gramfort <alexandre.gramfort@telecom-paristech.fr>
#
# License: BSD (3-clause)

print(__doc__)

import mne, os
import numpy as np
import cPickle as pickle
from mne import io
import scipy.signal
import scipy.io as spio
from mne.stats import permutation_cluster_test
from xfrange import xfrange

###############################################################################
# Set parameters
datDir = os.environ['DATDIR'] + 'Localized_trials/'
docPath = os.environ['DOCDIR'] + 'Localized-Epochs-Conditions/'
statsPath = '{}MEG_stats/LocalizedInvidualClusters/'.format(os.environ['DATDIR'])
groupNames = ['kids','adults']
regions = ['PAC','pSTG','pSTS','aSTG','aSTS','BA45','BA44','BA6v']
hemispheres = ['lh', 'rh']
markers = ['Obj','Subj']
metrics = ['normal','pooled']
filtering = 'filtered'
startTime = -0.5
endTime = 4.0
timescale = xfrange(startTime, endTime, 0.001)
startSample = int(np.round(startTime * 1000 + 1000))
endSample = int(np.round(endTime * 1000 + 1000))

# Load list of subjects
subjects = []
dirEntries = os.listdir(datDir)
for dirEntry in dirEntries:
	if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
		subjects.append(dirEntry)
subjects.sort()

for subject in subjects:
	metricID = 0
	metric = metrics[metricID]
	condition1 = {}
	condition2 = {}
	for region in regions:
		condition1[region] = {'lh':[], 'rh':[]}
		condition2[region] = {'lh':[], 'rh':[]}
	print ('Loading trials from subject {}'.format(subject))
	filesFound = True
	for markerID, marker in enumerate(markers):
		# Load localized activity
		activityFile = datDir + subject + '/' + marker + '_' + metric + '_' + filtering + '-epo.mat'
		if os.path.exists(activityFile):
			markerData = spio.loadmat(activityFile)
			for region in regions:
				for hem, hemisphere in enumerate(hemispheres):
					regionalData = []
					dataSet = np.squeeze(np.array(markerData[hemisphere + '_' + region]))
					for data in dataSet:
						regionalData.append(data[startSample:endSample,0])
					regionalData = np.array(regionalData)
					if marker == markers[0]:
						condition1[region][hemisphere].append(regionalData)
					elif marker == markers[1]:
						condition2[region][hemisphere].append(regionalData)
		else:
			print('File not found: {}'.format(activityFile))
			filesFound = False

# Cluster analysis
	# concatenate subject-specific trials
	if filesFound:
		subjectPath = docPath + filtering + '/' + subject + '/'
		if not os.path.isdir(subjectPath):
			os.makedirs(subjectPath)
		for hemisphere in hemispheres:
			for region in regions:
				filestem = subjectPath + region + '-' + hemisphere
				figFilename = filestem + '.png'
				statFilename = filestem + '.txt'
				print ('Region: {}-{}'.format(region, hemisphere))
				print len(condition1[region][hemisphere])
				c1 = np.squeeze(np.array(condition1[region][hemisphere]))
				c2 = np.squeeze(np.array(condition2[region][hemisphere]))
				print ('Condition 1: ', c1.shape)
				diffData = np.mean(c1, axis=0) - np.mean(c2, axis=0)
				print('DiffData: ', diffData.shape)

				###############################################################################
				# Compute statistic
				threshold = 2.0
				T_obs, clusters, cluster_p_values, H0 = permutation_cluster_test([c1, c2], n_permutations=2500, threshold=threshold, tail=1, n_jobs=16)

				###############################################################################
				# Plot
				import matplotlib.pyplot as plt
				plt.close('all')
				plt.subplot(211)
				plt.title('Region: {}-{}'.format(region, hemisphere))
				plt.plot(timescale, diffData, label="ERF Contrast (ORC - SRC)")
				plt.ylabel('Cortical activation (differential z-values)')
				plt.legend()
				plt.subplot(212)
				statFile = open(statFilename, 'w')
				if len(clusters) > 0:
					for i_c, c in enumerate(clusters):
						c = c[0]
						p = cluster_p_values[i_c]
						statFile.write('Cluster {:g} - {:g} with p-value of {:g}\n'.format(c.start, c.stop, p))
						if p <= 0.05:
							h = plt.axvspan(timescale[c.start], timescale[c.stop - 1], color='r', alpha=0.3)
						else:
							h = plt.axvspan(timescale[c.start], timescale[c.stop - 1], color=(0.3, 0.3, 0.3), alpha=np.power((1-p),2))
					hf = plt.plot(timescale, T_obs, 'g')
					plt.xlabel("time (ms)")
					plt.ylabel("f-values")
					plt.savefig(figFilename)
				statFile.close()
