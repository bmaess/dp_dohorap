import os
icapath = '/scr/kuba2/Dohorap/Main/Data/doc/ICAcleaning/'
icaimages = os.listdir(icapath)
icaimages.sort()
subjectDB = dict()
subjects = []
for icaimage in icaimages:
	if 'dh' in icaimage:
		subject = int(icaimage[2:4])
		if subject in subjectDB:
			subjectDB[subject].append(icaimage)
		else:
			subjectDB[subject] = [icaimage,]
		if subject not in subjects:
			subjects.append(subject)
for subject in subjects:
	infiles = [icapath + f for f in subjectDB[subject]]
	outfile = icapath + 'dh{:02d}a.png'.format(subject)
	os.system('montage ' + ' '.join(infiles) + ' -tile 3x -geometry 384x384+5+5 ' + outfile)
