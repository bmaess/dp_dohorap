"""
==================================
Compute ICA components on raw data
==================================

ICA is used to decompose raw data in 49 to 50 sources.
The source matching the ECG is found automatically
and displayed. Subsequently, the cleaned data is compared
with the uncleaned data. The last section shows how to export
the sources into a fiff file for further processing and displaying, e.g.
using mne_browse_raw.

This process takes about 75 minutes per block on kuba
"""
import mne, os
from multiprocessing import Pool
from mne.fiff import Raw
from mne.preprocessing.ica import ICA

def loadBads(fName):
	f = open(fName,'r').read().split('\n')
	badChanLibrary = {}
	for line in f:
		if len(line) > 0:
			if line[0] != '#':
				blockParts = {}
				lineparts = line.split(' ')
				lineLength = len(lineparts)
				if lineLength > 2:
					subjectID = int(lineparts[0])
					block = int(lineparts[1])
					badChans = []
					if lineparts[2] != '-':
						for i in range(lineLength-2):
							badChan = int(lineparts[i+2])
							badChanString = 'MEG{:#04d}'.format(badChan)
							badChans.append(badChanString)
					if subjectID not in badChanLibrary:
						blockParts[block] = badChans
						badChanLibrary[subjectID] = blockParts
					else:
						badChanLibrary[subjectID][block] = badChans
	return badChanLibrary

def runICA(subjectID):
	jumpAmplitudes = dict(grad=400e-12, mag=6e-12)
	subject = 'dh{:#02d}a'.format(subjectID)
	subjectPath = data_path + '/MEG_mc_hp004/' + subject + '/block'
	for block in ['1','2']:
		outfilename = subjectPath + block + '_ica.fif'
		raw_fname = subjectPath + block + '.fif'
		if os.path.exists(raw_fname):
			raw = Raw(raw_fname, preload=True)
			raw.info['bads'] = badChanLibrary[subjectID][int(block)]
			MEG_channels = mne.fiff.pick_types(raw.info, meg=True, eeg=False, eog=False, stim=False)
			ica = ICA(n_components=0.99, n_pca_components=64, max_pca_components=100, noise_cov=None, random_state=17259)

			# decompose sources for raw data
			ica.fit(raw, picks=MEG_channels, reject=jumpAmplitudes, tstep=1.0)

			# Save ICA results for diagnosis and reconstruction
			ica.save(outfilename)

		else:
			print(raw_fname + ' does not exist. Skipping ICA.')

###############################################################################
# Setup paths and prepare raw data
data_path = os.environ['DATDIR']
subjectIDs = range(2,20) + range(52,72)
badChanLibrary = loadBads(os.environ['BATDIR'] + 'config/badChans.txt')
pool = Pool(6)
feedback = pool.map(runICA, subjectIDs)
pool.close()
pool.join()
