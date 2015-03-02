import os
import mne

def calculateCovariance(subjectID):
	subject = 'dh{:#02d}a'.format(subjectID)
	print 'Computing covariance'
	# Check if there's an empty room measurement available
	rawFilenames = [os.environ['DATDIR'] + 'MEG_mc/' + subject + '/emptyRoom' + block + '.fif' for block in ['Previous','After']]
	validRawFilenames = []
	for rawFilename in rawFilenames:
		if os.path.exists(rawFilename):
			validRawFilenames.append(rawFilename)

	if len(validRawFilenames) > 0:
		raw = mne.fiff.Raw(validRawFilenames)
		MEG_channels = mne.pick_types(raw.info, meg=True, eeg=False, eog=False, stim=False)
		cov = mne.compute_raw_data_covariance(raw, picks=MEG_channels, reject=None, verbose=None)
		cov.save(os.environ['DATDIR'] + 'MEG_mc/' + subject + '/emptyRoom-cov.fif')

	else:
		print('No empty room measurements found; skipping ' + subject)

subjectIDs = range(2,20) + range(52,72)
for subjectID in subjectIDs:
	calculateCovariance(subjectID)
