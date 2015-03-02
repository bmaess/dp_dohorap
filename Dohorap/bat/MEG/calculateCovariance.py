# takes 60 minutes
import os, mne

def calculateCovariance(subjectID):
	subject = 'dh{:#02d}a'.format(subjectID)
	MEGDir = os.environ['DATDIR'] + 'MEG_mc_hp004_ica_l50/' + subject
	for cond in conds:
		covFile = '{}/{}-cov.fif'.format(MEGDir, cond)
		epochFile = '{}/{}_filtered-epo.fif'.format(MEGDir, cond)
		if os.path.exists(epochFile):
			epochs = mne.read_epochs(fname=epochFile)
			cov = mne.compute_covariance(epochs, tmin=0.0, tmax=tmaxes[cond])
			cov.save(covFile)

conds = ['Vis', 'Feed']
tmaxes = {'Vis':1.0, 'Feed':0.5}
subjectIDs = range(4,20) + range(52,72)
for subjectID in subjectIDs:
	calculateCovariance(subjectID)
