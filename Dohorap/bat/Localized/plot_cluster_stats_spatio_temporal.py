"""
=================================================================
Permutation t-test on source data with spatio-temporal clustering
=================================================================

Tests if the evoked response is significantly different between
conditions across subjects (simulated here using one subject's data).
The multiple comparisons problem is addressed with a cluster-level
permutation test across space and time.

"""
# Author:       Dominic Portain
# adapted from: Alexandre Gramfort <gramfort@nmr.mgh.harvard.edu>
#               Eric Larson <larson.eric.d@gmail.com>
# License: BSD (3-clause)

import numpy as np
from scipy import stats as stats

import mne
from mne import fiff, spatial_tris_connectivity, grade_to_tris
from mne.stats import spatio_temporal_cluster_1samp_test, summarize_clusters_stc
from mne.viz import mne_analyze_colormap
import os

###############################################################################
# Set parameters
MEG_path = os.environ['LOCDIR']
MRI_path = os.environ.get('SUBJECTS_DIR')
statsPath = os.environ['DATDIR'] + 'MEG_stats/'
os.environ['subjects_dir'] = MRI_path
tFilename = statsPath + 'SpatioTemporalClusters/T_obs.pickle'
clusterFilename = statsPath + 'SpatioTemporalClusters/clusters.pickle'
pFilename = statsPath + 'SpatioTemporalClusters/cluster_p_values.pickle'
hFilename = statsPath + 'SpatioTemporalClusters/H0.pickle'
summaryFilename = statsPath + 'SpatioTemporalClusters/stc_all_cluster_vis.pickle'

subjectList = [52,53,54,55,56,57,58,59,60,62,63,64,65,67,68,69,71]
p_threshold = 0.05
#subjectList = [52,53]
conditionText = ['Obj','Subj']
multitasking = 4
tstep = 0.001

# Load subject data
conditions = [0,1]
subjectCount = len(subjectList)
for subject in xrange(subjectCount):
	for condition, c in enumerate(conditionText):
		s = '{:#02d}'.format(subjectList[subject])
		stc_fname = MEG_path + '/dh{}a/{}_signed-lh.stc'.format(s,c)
		print('Loading {}'.format(stc_fname))
		stc = mne.read_source_estimate(stc_fname)
		n_vertices_fsave, n_times = stc.data.shape
		if subject == 0:
			# Initialize the target data variables
			vertices,timepoints = stc.data.shape
			subjectData = np.zeros((vertices, timepoints, len(conditions)))
			if condition == 0:
				X = np.zeros((vertices,2500,subjectCount))
		subjectData[:,:,condition] = stc.data
	# Calculate the paired contrast
	X[:, :, subject] = subjectData[:,1000:3500,0] - subjectData[:,1000:3500,1]
os.system('echo \"Subject data loaded\" | mail -s \"Status Dohorap\" portain@cbs.mpg.de')

###############################################################################
# Compute statistic

#    To use an algorithm optimized for spatio-temporal clustering, we
#    just pass the spatial connectivity matrix (instead of spatio-temporal)
print 'Computing connectivity.'
connectivity = spatial_tris_connectivity(grade_to_tris(5))

#    Note that X needs to be a multi-dimensional array of shape
#    samples (subjects) x time x space, so we permute dimensions
X = np.transpose(X, [2, 1, 0])
#    Now let's actually do the clustering. This can take a long time...
t_threshold = -stats.distributions.t.ppf(p_threshold / 2., subjectCount - 1)
print 'Clustering with a threshold of t = {}'.format(t_threshold)
clu = spatio_temporal_cluster_1samp_test(X, connectivity=connectivity, n_jobs=multitasking, threshold=t_threshold)
T_obs, clusters, cluster_p_values, H0 = clu
# Save this data for later reference
tFile = open(tFilename, 'w')
pickle.dump(T_obs, tFile)
tFile.close()

clusterFile = open(clusterFilename, 'w')
pickle.dump(clusters, clusterFile)
clusterFile.close()

pFile = open(pFilename, 'w')
pickle.dump(cluster_p_values, pFile)
pFile.close()

hFile = open(hFilename, 'w')
pickle.dump(H0, hFile)
hFile.close()

#    Now select the clusters that are sig. at p < 0.05 (note that this value
#    is multiple-comparisons corrected).
good_cluster_inds = np.where(cluster_p_values < 0.05)[0]
clusterCount = len(good_cluster_inds)

if clusterCount != 0:
	#    Now let's build a convenient representation of each cluster, where each
	#    cluster becomes a "time point" in the SourceEstimate
	fsave_vertices = fsave_vertices = [np.arange(vertices/2), np.arange(vertices/2)]
	stc_all_cluster_vis = summarize_clusters_stc(clu, tstep=tstep, vertno=fsave_vertices, subject='fsaverage')

	summaryFile = open(summaryFilename, 'w')
	pickle.dump(stc_all_cluster_vis, summaryFile)
	summaryFile.close()

	os.system('echo \"Cluster computation complete, {} clusters found\" | mail -s \"Status Dohorap\" portain@cbs.mpg.de'.format(clusterCount))
else:
	os.system('echo \"Cluster computation failed, no clusters found\" | mail -s \"Status Dohorap\" portain@cbs.mpg.de')
