import mne
import os
import numpy as np
import matplotlib.pyplot as plt

def cleanName(name):
	artifacts = ['.','-']
	for artifact in artifacts:	
		if artifact in name:
			name = name.replace(artifact,'')
	return name
	
expDir = os.environ['EXPDIR']
subjectsDir = os.environ['SUBJECTS_DIR']
docDir = os.environ['DOCDIR']
doPlot = False

subjectIDs = [8,11,12,14,15,16,52,53,54,55,57,58,59,60,62,63,64,65,66,67,68,69]
ROIsLeft  = ['aSTG-lh', 'pSTG-lh', 'Opercular-lh', 'PAC-lh', 'parsorbitalis-lh', 'lh.BA44', 'lh.BA45']
ROIsRight = ['aSTG-rh', 'pSTG-rh', 'Opercular-rh', 'PAC-rh', 'parsorbitalis-rh', 'rh.BA44', 'rh.BA45']
ROIs = ROIsLeft + ROIsRight
labelsDir = subjectsDir + 'dh53a' + '/label'
conditionNames = ['Object-first', 'Subject-first']
conditionColors = ['#0000FF','#A00000']
sideColors = ['#18b758','#c5a325']

differentialActivities = dict()

for s in subjectIDs:
	subject = 'dh' + '{:02d}'.format(s) + 'a'
	print subject
	activities = dict()
	conditions = [1,2]

	for roi in ROIs:
		if doPlot:
			# Prepare plot
			plt.figure()
			plt.axes([.1, .275, .85, .625])
			handles = [[0]*len(conditions)]*2
			h = 0
		
		for condition in conditions:
			# Load source activity
			stcFile = expDir + subject + '/' + subject + '-decision-c' + str(condition) + '-lh.stc'
			sourceActivity = mne.read_source_estimate(stcFile)
			labelFile = labelsDir + '/' + roi + '.label'

			# Select only the labeled activity
			roiLabel = mne.read_label(labelFile)			
			roiActivity = sourceActivity.in_label(roiLabel)

			# Average the selected activity
			averageActivity = roiActivity.data.mean(0)
			activities[roi+str(condition)] = averageActivity

			# Plot the time course
			if doPlot:
				handles[0][h] = plt.plot(sourceActivity.times, averageActivity, conditionColors[h], label=conditionNames[condition-1])
				h += 1
	
		# Finish the plot
		if doPlot:
			plt.xlabel('Time (s)')
			plt.ylabel('Source amplitude (MNE)')
			plt.xlim(sourceActivity.times[0], sourceActivity.times[2200])
			plt.legend()
			plt.suptitle('Activation in subject ' + str(s) + ', ' + roi, fontsize=18)
			imageFile = docDir + 'ROIactivity/' + subject + '-' + cleanName(roi) + '.png'
			plt.savefig(imageFile, dpi=300)
			plt.close()
	
	for roi in ROIs:
		differentialActivity = activities[roi+str(conditions[0])] - activities[roi+str(conditions[1])]
		differentialActivities[str(s)+roi] = differentialActivity


# Second plot with grand average differences
ROIs = [ROIsLeft,ROIsRight]
for r in xrange(len(ROIsLeft)):
	plt.figure()
	plt.axes([.1, .275, .85, .625])
	handles = [0,0]
	h = 0
	for side in [0,1]:
		cumulativeRoiActivity = np.zeros([averageActivity.size,len(subjectIDs)])
		for s in subjectIDs:
			i = subjectIDs.index(s)
			differentialActivity = differentialActivities[str(s)+ROIs[side][r]]
			cumulativeRoiActivity[:,i] = differentialActivity
		roiActivity  = cumulativeRoiActivity.mean(1)
		handles[h] = plt.plot(sourceActivity.times, roiActivity, sideColors[h], label=ROIs[side][r])
		h += 1
	# Finish the plot
	plt.xlabel('Time (s)')
	plt.ylabel('Source amplitude difference (MNE)')
	plt.xlim(sourceActivity.times[0], sourceActivity.times[2200])
	plt.legend()
	plt.suptitle('Activation difference', fontsize=18)
	imageFile = docDir + 'ROIactivity/' + 'GrandAverage-' + cleanName(ROIsLeft[r]) + '.png'
	plt.savefig(imageFile, dpi=300)
	plt.close()
