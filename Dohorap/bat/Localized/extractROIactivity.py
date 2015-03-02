import mne, os
import numpy as np
import scipy.io as spio
import signal, time
from multiprocessing import Pool

def initWorker():
	signal.signal(signal.SIGINT, signal.SIG_IGN)

def calculateInverse(subject, cfg):
	subjectsDir = cfg['subjectsDir']
	ROIs = cfg['ROIs']
	datDir = os.environ['DATDIR']
	BEMdir = os.environ['BEMDIR']
	MEGdir = datDir + 'MEG_mc_hp004_ica_l50/'
	locDir = datDir + 'Localized_trials/'
	labelsDir = subjectsDir + 'dh55a' + '/label/Dohorap/'

	inverseMethod = 'sLORETA'
	SNR = 100.0 # generously more than the ratio between amplitudes of single and average trials
		         # high value is justified because I'm modelling all the distracting activity as well, so that I only have environmental noise left
	lambda2 = 1.0 / SNR ** 2

	hemispheres = ['lh','rh']
	localization = 0
	localizationTypes = [None,'normal']
	localizationText = ['pooled','normal']
	filterings = ['unfiltered', 'filtered']
	eventIDs = ['Obj', 'Subj']

	inverseFile = BEMdir + subject + '/' + subject + '__-5120-ico-5p-' + subject + '-aligned-inv.fif'
	print inverseFile
	if os.path.exists(inverseFile):

		# Load inverse operator
		inverseOperator = mne.minimum_norm.read_inverse_operator(inverseFile)

		# Prepare paths
		outDir = locDir + '/' + subject + '/'
		if not os.path.isdir(outDir):
			os.makedirs(outDir)
		for filtering in filterings:
			for condition in eventIDs:
				epochsFilename = MEGdir + subject + '/' + filtering + '_' + condition + '-epo.fif'
				epochs = mne.read_epochs(epochsFilename)
				activityFile = outDir + condition + '_' + localizationText[localization] + '_' + filtering + '-epo.mat'
				if os.path.exists(activityFile):
					os.remove(activityFile)
				matlabDict = dict()
				for hemisphere in hemispheres:
					for roi in ROIs:
						# Load label file (morphing not necessary (?))
						label = mne.read_label(labelsDir + hemisphere + '.' + ROIs[roi] + '.label')

						# Convert to source space, but only within the selected ROI
						stcs = mne.minimum_norm.apply_inverse_epochs(epochs, inverseOperator, lambda2, inverseMethod, label=label, pick_ori=localizationTypes[localization], nave=1) # quite loud, but verbose does nothing
						matlabDict[hemisphere + '_' + roi] = np.zeros((len(stcs),), dtype=np.object)
						# Compute the average for each trial
						for trial, stc in enumerate(stcs):
							label_mean = np.mean(stc.data, axis = 0) # average across vertices in this label

							# Store the average activity in the corresponding cell array
							matlabDict[hemisphere + '_' + roi][trial] = label_mean

				# Write the Matlab dictionary to disk
				epochs = None
				spio.savemat(activityFile, matlabDict, do_compression=True)
	else:
		print 'Inverse operator not found, skipping ' + subject

def main():
	subjectsDir = os.environ['SUBJECTS_DIR']
	# Load labels of interest
	labelFileName = subjectsDir + 'a2009s labels.txt'
	ROIs = dict()
	labelFile = open(labelFileName,'r').readlines()
	for labelLine in labelFile:
		while '\n' in labelLine:
			labelLine = labelLine.replace('\n', '')
		labelParts = labelLine.split(': ')
		ROIs[labelParts[0]] = labelParts[1]

	# Determine individual subject folders
	subjects = []
	dirEntries = os.listdir(subjectsDir)
	for dirEntry in dirEntries:
		if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
			subjects.append(dirEntry)
	subjects.sort()

	cfg = {}
	cfg['subjectsDir'] = subjectsDir
	cfg['ROIs'] = ROIs

	multitasking = True # switch off for debugging
	pool = Pool(12, initWorker) # 12 is a good value for eber, 16 fills it completely
	feedback = []
	if multitasking:
		try:
			for subject in subjects:
				print('Starting subject', subject)
				feedback.append(pool.apply_async(calculateInverse, (subject, cfg, )))
				time.sleep(15) # Delayed onset to reduce disk traffic on kuba
			pool.close()
			while True:
				if all(f.ready() for f in feedback):
					print "All processes completed"
					return
				time.sleep(1)

		except KeyboardInterrupt:
			print "Caught KeyboardInterrupt, terminating workers"
			pool.terminate()
			pool.join()
	else:
		for subject in subjects:
			calculateInverse(subject, cfg)

if __name__ == "__main__":
	main()
