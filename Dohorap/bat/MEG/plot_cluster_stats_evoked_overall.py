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
from mne.stats import permutation_cluster_test

def stringify(subjectNumbers):
	return ['dh{:#02d}a'.format(subjectNumber) for subjectNumber in subjectNumbers]

def baseline(data):
	for channel in range(data.shape[0]):
		d = data[channel,:]
		b = np.mean(d[800:1000])
		data[channel,:] -= b
	return data

###############################################################################
# Set parameters
data_path = os.environ['EXPDIR']
docPath = os.environ['DOCDIR'] + 'MEG-Epochs-Conditions/'
groups = [stringify(range(4,13) + range(14,17)), stringify(range(52,61) + range(62,70) + range(71,72))]
#groups = [stringify(range(6,9)), stringify(range(52,55))]
rawFile = os.environ['RAWDIR'] + 'dh53a/dh53a1.fif'
groupNames = ['kids','adults']
raw = mne.fiff.Raw(rawFile)
tmin = -1.0
tmax = 4.0
areas = ['temporal', 'frontal', 'parietal']
hemispheres = ['Left','Right']
sensortypes = ['grad','mag']
regions = []
for area in areas:
	for hemisphere in hemispheres:
		regions.append('-'.join([hemisphere, area]))

for sensor in sensortypes:
	for groupID, group in enumerate(groups):
		statsPath = os.environ['DATDIR'] + 'MEG_stats/TemporalClusters/'
		groupName = groupNames[groupID]
		condition1 = {}
		condition2 = {}
		allFilesExist = True
		for region in regions:
			tFilename = '{}{}-{}-{}-T_obs.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			clusterFilename = '{}{}-{}-{}-clusters.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			pFilename = '{}{}-{}-{}-cluster_p_values.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			hFilename = '{}{}-{}-{}-H0.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			diffFilename = '{}{}-{}-{}-diff.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			filesExist = [os.path.exists(f) for f in [tFilename, clusterFilename, pFilename, hFilename, diffFilename]]
			if not all(filesExist):
				allFilesExist = False
		
		if not allFilesExist:
			for subjectID, subject in enumerate(group):
				###############################################################################
				# Read epochs for the channel of interest
				epoch1_fname = data_path + '/' + subject + '/filtered_Obj-epo.fif'
				epoch2_fname = data_path + '/' + subject + '/filtered_Subj-epo.fif'
				epochs1 = mne.read_epochs(fname=epoch1_fname)
				epochs2 = mne.read_epochs(fname=epoch2_fname)

				for region in regions:
					channelNames = mne.read_selection(region)
					channelShortNames = [channelName.replace(' ','') for channelName in channelNames]
					channelIDs = mne.pick_types(raw.info, meg=sensor, eeg=False, eog=False, stim=False, selection=channelShortNames)
					if region not in condition1:
						condition1[region] = []
					if region not in condition2:
						condition2[region] = []
					if sensor == 'grad':
						data1 = np.sqrt(np.mean(np.power(epochs1.get_data()[:,channelIDs, 500:3500], 2), axis=1))
						data2 = np.sqrt(np.mean(np.power(epochs2.get_data()[:,channelIDs, 500:3500], 2), axis=1))
					else:
						data1 = np.mean(epochs1.get_data()[:,channelIDs, 500:3500], axis=1)
						data2 = np.mean(epochs2.get_data()[:,channelIDs, 500:3500], axis=1)
					#sprint data1.shape # trials x samples
					condition1[region].append(data1)
					condition2[region].append(data2)
		else:
			epochs1 = mne.read_evoked(fname=data_path + '/dh53a/Obj_average-ave.fif')

		# concatenate subject-specific trials
		for region in regions:
			tFilename = '{}{}-{}-{}-T_obs.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			clusterFilename = '{}{}-{}-{}-clusters.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			pFilename = '{}{}-{}-{}-cluster_p_values.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			hFilename = '{}{}-{}-{}-H0.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			diffFilename = '{}{}-{}-{}-diff.pickle'.format(statsPath, groupNames[groupID], sensor, region)
			if not allFilesExist:
				figFilename = docPath + groupName + '_' + region + '_' + sensor + '.png'
				statFilename = docPath + groupName + '_' + region + '_' + sensor + '.txt'
				c1 = np.concatenate(condition1[region], axis = 0)
				c2 = np.concatenate(condition2[region], axis = 0)
				diffData = np.mean(c1, axis=0) - np.mean(c2, axis=0)

				###############################################################################
				# Compute statistic
				threshold = 1.0
				T_obs, clusters, cluster_p_values, H0 = permutation_cluster_test([c1, c2], n_permutations=2500, threshold=threshold, tail=1, n_jobs=4)
				

				pickle.dump(T_obs, open(tFilename, 'wb'))
				pickle.dump(clusters, open(clusterFilename, 'wb'))
				pickle.dump(cluster_p_values, open(pFilename, 'wb'))
				pickle.dump(H0, open(hFilename, 'wb'))
				pickle.dump(diffData, open(diffFilename, 'wb'))
			else:
				T_obs = pickle.load(open(tFilename,'rb'))
				clusters = pickle.load(open(clusterFilename,'rb'))
				cluster_p_values = pickle.load(open(pFilename,'rb'))
				H0 = pickle.load(open(hFilename,'rb'))
				diffData = pickle.load(open(diffFilename,'rb'))

			###############################################################################
			# Plot
			times = epochs1.times[500:3500]
			import matplotlib.pyplot as plt
			plt.close('all')
			plt.subplot(211)
			plt.title('Region: {}'.format(region))
			print times.shape, diffData.shape
			plt.plot(times, diffData, label="ERF Contrast (ORC - SRC)")
			if sensor == 'grad':
				plt.ylabel("MEG (T / m)")
			else:
				plt.ylabel('MEG (T)')
			plt.legend()
			plt.subplot(212)
			statFile = open(statFilename, 'w')
			if len(clusters) > 0:
				for i_c, c in enumerate(clusters):
					c = c[0]
					p = cluster_p_values[i_c]
					statFile.write('Cluster {:g} - {:g} with p-value of {:g}\n'.format(c.start, c.stop, p))
					if p <= 0.05:
						h = plt.axvspan(times[c.start], times[c.stop - 1], color='r', alpha=0.3)
					else:
						h = plt.axvspan(times[c.start], times[c.stop - 1], color=(0.3, 0.3, 0.3), alpha=(1-p))
				hf = plt.plot(times, T_obs, 'g')
				plt.xlabel("time (ms)")
				plt.ylabel("f-values")
				plt.savefig(figFilename)
			statFile.close()
