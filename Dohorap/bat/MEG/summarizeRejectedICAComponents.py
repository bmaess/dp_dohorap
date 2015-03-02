from __future__ import division
import os
basePath = os.environ['DATDIR'] + '/MEG_mc_hp004_ica/'
subjects = os.listdir(basePath)
components = {}
for subject in subjects:
	subjectComponents = {}
	if subject.startswith('dh'):
		epochFile = basePath + subject + '/removedICAcomponents.log'
		epochText = open(epochFile,'r').read().split('\n')
		for epochLine in epochText:
			fragmentParts = epochLine.split(' ')
			if epochLine.startswith('Processing'):	
				block = int(fragmentParts[-1])
			if epochLine.startswith('Excluding'):
				number = fragmentParts[2][0:-1]
				component = int(number)
				if block not in subjectComponents:
					subjectComponents[block] = [component,]
				else:
					subjectComponents[block].append(component)
		components[subject] = subjectComponents

totalComponentCount = 0
totalBlockCount = 0
for subject in components:
	subjectComponents = components[subject]
	blockCount = len(subjectComponents)
	totalBlockCount += blockCount
	componentCount = 0
	maxComponents = 0
	minComponents = 10
	for block in subjectComponents:
		componentCount += len(subjectComponents[block])
		maxComponents = max([len(subjectComponents[block]), maxComponents])
		minComponents = min([len(subjectComponents[block]), minComponents])
	totalComponentCount += componentCount
	average = componentCount / blockCount
	print('Components removed in {}: minimum {}, average {}, maximum {})'.format(subject, minComponents, average, maxComponents))
grandAverage = totalComponentCount / totalBlockCount
print('Average components remove overall: {}'.format(grandAverage))
