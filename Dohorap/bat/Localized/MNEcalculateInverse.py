from multiprocessing import Pool
import os

def calculateInverse(subjectID):
	subject = 'dh{:#02d}a'.format(subjectID)
	# reg = '{:0.8f}'.format(regData[subjectID])
	reg = '0.001'
	os.system(batdir + 'MNEcalculateInverse.sh ' + subject + ' ' + reg)

def readRegularization(regFilename):
	regFile = open(regFilename,'r').read().split('\n')
	regularizations = dict()
	for line in regFile:
		lineParts = line.split(' ')
		validLine = True
		try:
			subject = int(lineParts[0])
			regularizations[subject] = float(lineParts[2])
		except ValueError, IndexError:
			validLine = False
			pass
	return regularizations

batdir = os.environ['BATDIR'] + 'Localized/'
MEGdir = os.environ['DATDIR'] + 'MEG_mc_hp004_ica_l50'
subjectIDs = range(2,13) + range(14,17) + range(52,61) + range(62,66) + range(67, 70) + range(71,72)
regFilename = MEGdir + '/regularization.txt'
regData = readRegularization(regFilename)
pool = Pool(8) # each process uses up to 6 cores and 600-800MB of RAM
feedback = pool.map(calculateInverse, subjectIDs)
pool.close()
pool.join()
#for subjectID in subjectIDs:
#	calculateInverse(subjectID)
