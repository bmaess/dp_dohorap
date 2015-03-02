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
from mne import io
from mne.stats import permutation_cluster_test
from mne.datasets import sample

def stringify(subjectNumbers):
	return ['dh{:#02d}a'.format(subjectNumber) for subjectNumber in subjectNumbers]

###############################################################################
# Set parameters
data_path = os.environ['EXPDIR']
docPath = os.environ['DOCDIR'] + 'MEG-Epochs-Conditions/'
groups = [stringify(range(4,20)), stringify(range(52,72))]
rawFile = os.environ['RAWDIR'] + 'dh53a/dh53a1.fif'
raw = mne.fiff.Raw(rawFile)
tmin = -1.0
tmax = 3.0

for group in groups:
	for subject in group:
		event1_fname = data_path + '/' + subject + '/Obj-epo.fif'
		event2_fname = data_path + '/' + subject + '/Subj-epo.fif'
		figFilename = docPath + subject + '.png'
		statFilename = docPath + subject + '.txt'

		channelNames = mne.read_selection('Left-frontal')
		channelShortNames = [channelName.replace(' ','') for channelName in channelNames]
		channelIDs = mne.pick_types(raw.info, meg='mag', eeg=False, eog=False, stim=False, selection=channelShortNames)

		###############################################################################
		# Read epochs for the channel of interest
		epochs1 = mne.read_epochs(fname=event1_fname)
		condition1 = epochs1.get_data()  # as 3D matrix

		epochs2 = mne.read_epochs(fname=event2_fname)
		condition2 = epochs2.get_data()  # as 3D matrix

		condition1 = np.mean(condition1[:, channelIDs, :],axis=1)  # take only one channel to get a 2D array
		condition2 = np.mean(condition2[:, channelIDs, :],axis=1)  # take only one channel to get a 2D array

		###############################################################################
		# Compute statistic
		threshold = 1.0
		T_obs, clusters, cluster_p_values, H0 = \
				          permutation_cluster_test([condition1, condition2],
				                      n_permutations=1000, threshold=threshold, tail=1,
				                      n_jobs=4)

		###############################################################################
		# Plot
		times = epochs1.times
		import matplotlib.pyplot as plt
		plt.close('all')
		plt.subplot(211)
		plt.title('Channels: left frontal')
		plt.plot(times, condition1.mean(axis=0) - condition2.mean(axis=0),
				   label="ERF Contrast (Event 1 - Event 2)")
		plt.ylabel("MEG (T / m)")
		plt.legend()
		plt.subplot(212)
		statFile = open(statFilename, 'w')
		for i_c, c in enumerate(clusters):
			c = c[0]
			p = cluster_p_values[i_c]
			statFile.write('Cluster {:g} - {:g} with p-value of {:g}\n'.format(c.start, c.stop, p))
			if p <= 0.05:
				h = plt.axvspan(times[c.start], times[c.stop - 1], color='r', alpha=1-p)
			else:
				h = plt.axvspan(times[c.start], times[c.stop - 1], color=(0.3, 0.3, 0.3), alpha=1-p)
		hf = plt.plot(times, T_obs, 'g')
		plt.legend((h, ), ('cluster p-value < 0.05', ))
		plt.xlabel("time (ms)")
		plt.ylabel("f-values")
		plt.savefig(figFilename)
		statFile.close()
