import os
excludedExtensions = ['.mex', '.pyc', '~']
fileNames = []
for dirname, dirnames, filenames in os.walk('.'):
	for filename in filenames:
		if '.' not in dirname[1:]:
			exclude = False
			for excludedExtension in excludedExtensions:
				if excludedExtension in filename:
					exclude = True
			if not exclude:
				fileNames.append(os.path.join(dirname, filename))

outFile = open('ModuleTemplate.txt','w')

weakDependencies = dict()
strongDependencies = dict()
for inFileName in fileNames:
	s = []
	w = []
	inFile = open(inFileName,'r').read()
	for outFileName in fileNames:
		f = outFileName.split('/')
		if f[-1] in inFile:
			s.append(outFileName)
		else:
			o = f[-1].split('.')
			if o[0] in inFile:
				w.append(outFileName)
	weakDependencies[inFileName] = w
	strongDependencies[inFileName] = s

for fileName in fileNames:
	outFile.write(fileName + '\n')
	outFile.write(''.join(['-']*len(fileName)))
	outFile.write('\nProcess:\nInput:\nOutput:\nDependencies:\n')
	for s in strongDependencies[fileName]:
		outFile.write('strong: ' + s + '\n')
	for w in weakDependencies[fileName]:
		outFile.write('weak: ' + w + '\n')
	outFile.write('\n')
