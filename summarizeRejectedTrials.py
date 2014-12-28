from __future__ import division
import os
basePath = '/Volumes/Dohorap/Dohorap/Main/Data/MEG_mc_hp004_ica_l50/'
subjects = os.listdir(basePath)
trials = {}
conditions = []
for subject in subjects:
	if subject.startswith('dh'):
		epochFile = basePath + subject + '/epochCount.txt'
		epochText = open(epochFile,'r').read().split('\n')
		for epochLine in epochText:
			if epochLine.startswith('Artifact-free'):
				conditionPos = epochLine.index('condition')
				conditionFragment = epochLine[conditionPos + 10:]
				fragmentParts = conditionFragment.split(': ')
				condition = fragmentParts[0]
				if condition not in conditions:
					conditions.append(condition)
				trialCount = int(fragmentParts[1])
				if condition not in trials:
					trials[condition] = trialCount
				else:
					trials[condition].append(trialCount)

for condition in conditions:
	average = sum(trials[condition]) / len(trials[condition])
	print('Average trials in condition {}: {}'.format(condition, average))