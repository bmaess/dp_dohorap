import os, math

groups = ['adults','kids']
regions = ['frontal','temporal','parietal']
basePath = os.environ['DATDIR'] + '/MEG_stats'
timeslots = ['A','B','C']
hemispheres = ['lh','rh']
sensors = ['Mag', 'Grad']
outString = []
for sensor in sensors:
	significantFindings = [0,0,0]
	totalTests = 0
	for group in groups:
		for hemisphere in hemispheres:
			for region in regions:
				outString.append('Probability that conditions produced identical activity in {}-{} {} for {}:\n'.format(region, hemisphere, sensor, group))
				smallestP = 1.0
				for timeslot in timeslots:
					textFilename = '{}/{}/{}-{}_{}_{}.txt'.format(basePath, group, region, hemisphere, timeslot, sensor)
					textFile = open(textFilename,'r').read().split('\n')
					p = None
					for line in textFile:
						if len(line) > 0:
							if 'cond' in line:
								lineparts = line.split(' ')
								while ('') in lineparts:
									lineparts.remove('')
								p = float(lineparts[5])
								F = float(lineparts[4])
								if p < 0.1:
									significantFindings[0] += 1
								if p < 0.05:
									significantFindings[1] += 1
								if p < 0.01:
									significantFindings[2] += 1
					totalTests += 1
					smallestP = min([p, smallestP])
					if p != None:
						accuracy = int(-(math.floor(math.log10(p))) - 1)
						outTemplate = '{}: p = {:.' + str(accuracy) + '%}, F = {:1.2}'
						outString.append(outTemplate.format(timeslot, p, F))
						if timeslot == timeslots[-1]:
							outString.append('  ')
							if smallestP < 0.1:
								if smallestP < 0.05:
									if smallestP < 0.01:
										outString.append('**')
									else:
										outString.append('*')
								else:
									outString.append('-')
							outString.append('\n\n')
						else:
							outString.append(',  ')
					
	outString.append('\nNumber of findings:\n')
	outString.append('  Barely significant: {}/{}\n'.format(significantFindings[0], totalTests))
	outString.append('  Significant: {}/{}\n'.format(significantFindings[1], totalTests))
	outString.append('  Very significant: {}/{}\n'.format(significantFindings[2], totalTests))

outFile = open(basePath + '/summary-MEG.txt','w')
outFile.write(''.join(outString))
print ''.join(outString)
outFile.close()
