import mne
import os
import numpy as np
import scipy.io as spio
from mne import fiff
from multiprocessing import Pool

def cleanName(name):
	artifacts = ['lh','.','-']
	for artifact in artifacts:	
		if artifact in name:
			name = name.replace(artifact,'')
	return name

def extractActivity(s):
	for condition in conditions:
		subject = 'dh' + '{:02d}'.format(int(s)) + 'a'
		inverseFile = expDir + subject + '/' + subject + '__-5120-ico-5p-' + subject + '-aligned-inv.fif'

		# Estimate SNR
		snr = 3.0
		regularization = 1.0 / (snr ** 2)

		print 'Prepare saving'
		activityFile = datDir + subject + '/' + condition + '_average.mat'
		matlabDict = {}
		print 'Populate a dictionary with Matlab variables named after the ROI'
		matlabDict['conditions'] = np.array(conditions, dtype=np.object)
		for roi in ROIs:
			# Prepare each variable as a cell array for the single trials
			matlabDict[cleanName(roi)] = np.zeros((1,), dtype=np.object)

		print 'Load inverse operator'
		inverseOperator = mne.minimum_norm.read_inverse_operator(inverseFile)
		
		print 'Load evoked file'
		evokedFile = expDir + subject + '/' + subject + '_mc_hp004_l80_' + condition + '_average-ica.fif'
		evoked = mne.fiff.Evoked(evokedFile, condition=0, baseline=None)
		evoked.crop(tmin=0.0, tmax=0.01)
		      
		print 'Convert sensor space to source space'
		# sourceActivity = mne.minimum_norm.apply_inverse(evoked, inverseOperator, regularization, inverseMethod, pick_ori="normal")
		sourceActivity = mne.minimum_norm.apply_inverse(evoked, inverseOperator, regularization, inverseMethod, pick_ori="normal")
		print 'Morph to standard subject'
		morphedSourceActivity = mne.morph_data(subject, 'dh58a', sourceActivity, grade=5, smooth=20, subjects_dir=subjectsDir)

		for roi in ROIs:
		# Load the label of interest
			label = mne.read_label(labelsDir + '/' + roi + '.label')

			print 'Select only the labeled activity'
			roiActivity = sourceActivity.in_label(label)
			averageActivity = roiActivity.data.mean(0)
			#src = inverseOperator['src']
			#averageActivity = mne.extract_label_time_course(morphedSourceActivity, label, src, mode='mean_flip',return_generator=True)

			print 'Store the average activity in the corresponding cell array'
			matlabDict[cleanName(roi)] = averageActivity

		# Write the Matlab dictionary to disk
		spio.savemat(activityFile, matlabDict, do_compression=True)
	
datDir = os.environ['DATDIR'] + 'Localized_ROI/'
expDir = os.environ['EXPDIR']
subjectsDir = os.environ['SUBJECTS_DIR']
docDir = os.environ['DOCDIR']
labelsDir = subjectsDir + 'dh53a' + '/label'

subjectIDs = [range(2,20) + range(52,61) + range(62,70)]
ROIs = ['aSTG-lh', 'pSTG-lh', 'Opercular-lh', 'PAC-lh', 'parsorbitalis-lh', 'lh.BA44', 'lh.BA45']
inverseMethod = 'sLORETA'
conditions = ['Obj','Subj','Vis','Contrast']
groups = ['kids', 'adults']

#pool = Pool(1)
#feedback = pool.map(extractActivity, subjectIDs)
#pool.close()
#pool.join()
extractActivity(2)
