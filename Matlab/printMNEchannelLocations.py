import mne
directions = ['Left','Right']
locations = ['frontal','parietal','temporal','occipital']
separator = ', '
matlabText = []
evokedFile = '../averages/dh07a/Subj_average-ave.fif'
evoked = mne.fiff.Evoked(fname=evokedFile, condition=0, baseline=None, kind='average', verbose=False)
sensortypes = ['mag','grad']
for sensortype in sensortypes:
	for location in locations:
		for direction in directions:
			channelNames = mne.read_selection('{}-{}'.format(direction, location))
			channelShortNames = [channelName.replace(' ','') for channelName in channelNames]
			channelIDs = mne.pick_types(evoked.info, meg=sensortype, eeg=False, eog=False, stim=False, exclude='bads', selection=channelShortNames)
			channelIDtext = [str(channelID) for channelID in channelIDs]
			channelText = '{}_{}_{}'.format(direction, location, sensortype) + ' = [' + separator.join(channelIDtext) + '];\n'
			matlabText.append(channelText)
print(''.join(matlabText))