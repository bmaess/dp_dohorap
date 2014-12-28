import numpy as np

textFile = '/Volumes/Dohorap/Dohorap/Main/Data/doc/ICAcleaning/removeICAcomponents.log'
text = open(textFile, 'r').read().split('\n')
subjectIDs = []
components = {}
subjectID = '#'
for line in text:
	if line.startswith('Processing subject dh'):
		subjectPosition = line.index('dh')
		subject = line[subjectPosition+2 : subjectPosition+4]
		blockPosition = line.index('block')
		block = line[blockPosition+6]
		subjectID = subject + '-' + block
		subjectIDs.append(subjectID)
	if subjectID not in components:
		components[subjectID] = []
	if subjectID != '#':
		if line.startswith('Excluding'):
			exclusionPosition = line.index('component')
			componentText = line[exclusionPosition+10:exclusionPosition+15]
			componentParts = componentText.split(',')
			component = int(componentParts[0])
			components[subjectID].append(component)

groupCount = [[],[]]
componentCount = []
for subjectID in subjectIDs:
	subject = int(subjectID[0:2])
	if subject > 50:
		group = 1
	else:
		group = 0
	groupCount[group].append(len(components[subjectID]))
	componentCount.append(len(components[subjectID]))

data = componentCount
print('Rejected components: min {}, max {}, median {}'.format(min(data),max(data),np.median(data)))
groupText = ['Children','Adults']
for group in [0,1]:
	data = groupCount[group]
	print('Rejected components in group {}: min {}, max {}, median {}'.format(groupText[group], min(data),max(data),np.median(data)))