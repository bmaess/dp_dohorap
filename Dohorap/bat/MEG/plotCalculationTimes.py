import os, time
import numpy as np
import pylab as P
megPath = '/scr/kuba2/Dohorap/Main/Data/MEG/motionCorrected/'
files = dict()
times = []
for dirname, dirnames, filenames in os.walk(megPath):
	for filename in filenames:
		if '_mc_hp004_ica.fif' in filename:
			f = os.path.join(dirname, filename)
			t = os.path.getmtime(f)
			if t > 1402680000.0:
				times.append(t)
				files[t] = f
times.sort()
timeDifferences = []
for t in range(len(times)-1):
	difference = times[t+1] - times[t]
	print times[t], files[times[t]]
	if difference < 10000:
		timeDifferences.append(difference)
n, bins, patches = P.hist(timeDifferences, 10, normed=1, histtype='stepfilled')
P.setp(patches, 'facecolor', 'g', 'alpha', 0.75)
y = P.normpdf( bins, np.median(timeDifferences), np.sqrt(np.var(timeDifferences)))
l = P.plot(bins, y, 'k--', linewidth=1.5)
P.show()
