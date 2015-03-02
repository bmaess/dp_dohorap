from multiprocessing import Pool
import os

def calculateSTCs(subjectID):
	subject = 'dh{:#02d}a'.format(subjectID)
	os.system(batdir + 'MNEcalculateSTCs.sh ' + subject)

batdir = os.environ['BATDIR'] + 'Localized/'
subjectIDs = range(2,13) + range(14,17) + range(52,61) + range(62,70) + range(71,72)
pool = Pool(4) # MNEcalculateSTCs.sh uses exactly 840MB per subject
feedback = pool.map(calculateSTCs, subjectIDs)
pool.close()
pool.join()
