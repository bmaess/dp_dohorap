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

Only works on kuba, with the patched MNE 0.8.6

"""

import numpy as np
import pylab as pl
from scipy.signal import butter, lfilter
from string import join
import mne
import os, errno
from mne.fiff import Raw
from mne.preprocessing import read_ica
from multiprocessing import Pool

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

def force_symlink(file1, file2):
    try:
        os.symlink(file1, file2)
    except OSError, e:
        if e.errno == errno.EEXIST:
            os.remove(file2)
            os.symlink(file1, file2)

def reconstructICA(subjectID):
	subject = 'dh{:#02d}a'.format(subjectID)
	logFile = open(outPath + subject + '/removedICAcomponents.log', 'w')
	for block in ['1','2']:
		logFile.write('Processing subject ' + subject + ', block ' + block + '\n')
		subjectStub = subject + '/block' + block
		raw_fname = rawPath + subjectStub + '.fif'
		icaFile = rawPath + subjectStub + '_ica.fif'
		outFile = outPath + subjectStub + '.fif'
		if not os.path.isdir(outPath + subject):
			os.makedirs(outPath + subject)
		if os.path.exists(raw_fname):
			raw = Raw(raw_fname, preload=True)
			raw.info['bads'] = badChanLibrary[subjectID][int(block)]
			ica = read_ica(icaFile)
			#raw.ch_names = ica.ch_names

			# Select and filter interesting channels
			picks_eog = mne.pick_types(raw.info, meg=False, eeg=False, stim=False, eog=True,  ecg=False)
			picks_ecg = mne.pick_types(raw.info, meg=False, eeg=False, stim=False, eog=False, ecg=True)

			logFile.write('Rejecting components that correlate with EOG and ECG channels...\n')
			excluded_components = []
			eogChannel = picks_eog[1]
			eogNames = raw.ch_names[eogChannel]
			eog_idx, eog_scores = ica.find_bads_eog(raw, eogNames)
			for i in eog_idx:
				if i not in excluded_components:
					excluded_components.append(i)
				logFile.write("Excluding component {}, Correlation with EOG: {} \n".format(i, eog_scores[i]))

			ecgChannel = picks_ecg
			ecgNames = raw.ch_names[ecgChannel]
			ecg_idx, ecg_scores = ica.find_bads_ecg(raw, ecgNames)
			for i in ecg_idx:
				if i not in excluded_components:
					excluded_components.append(i)
				logFile.write("Excluding component {}, Correlation with ECG: {} \n".format(i, ecg_scores[i]))
		
			# Save corrected fif file
			if len(excluded_components) > 0:
				logFile.write('Saving corrected fif file\n')
				ica.apply(raw, exclude=excluded_components)
				raw.save(outFile, overwrite=True)
			else:
				logFile.write('Nothing to do; creating symlink\n')
				force_symlink(raw_fname, outFile)

	logFile.close()

###############################################################################
# Setup paths and prepare raw data
docPath = os.environ['DOCDIR'] + 'ICAcleaning/'
rawPath = os.environ['DATDIR'] + 'MEG_mc_hp004/'
outPath = os.environ['DATDIR'] + 'MEG_mc_hp004_ica/'
doPlot = False
subjectIDs = [71,]
#subjectIDs = range(4,13) + range(14,17) + range(52,61) + range(62,70) + range(72,73)
badChanLibrary = loadBads(os.environ['BATDIR'] + 'config/badChans.txt')
#pool = Pool(2)
#feedback = pool.map(reconstructICA, subjectIDs)
#pool.close()
#pool.join()
for subjectID in subjectIDs:
	reconstructICA(subjectID)
