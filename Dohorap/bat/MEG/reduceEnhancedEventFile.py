import os

subjectIDs = range(2,20) + range(52,72)
for subjectID in subjectIDs:
	subject = 'dh{:#02d}a'.format(subjectID)
	subjectPath = '/scr/kuba1/Dohorap/Main/Data/MEG_mc/' + subject + '/'

	for block in ['1','2']:
		# Get the offset from a basic event file
		rawfile = open(subjectPath + 'block' + block + '.eve', 'r')
		firstLine = rawfile.readline()
		rawfile.close()
		lineParts = firstLine.split(' ')
		while '' in lineParts: lineParts.remove('')
		offset = int(lineParts[0])

		# Open the enhanced 'der/den' event file
		enfile = open(subjectPath + 'block' + block + '-eh-derden.eve', 'r')
		outfile = open(subjectPath + 'block' + block + '-eh-nocomments.eve', 'w')
		enEvents = enfile.read().split('\n')
		# Write the 'new format' header line
		firstLine = '\t{:d}\t{:.3f}\t0\t0\n'.format(offset, offset/1000.0)
		outfile.write(firstLine)
		for event in enEvents:
			# Split each line into its components
			if len(event) > 0:
				if not event[0] == '#': # omit disabled lines
					eventParts = event.split(' ')
					while '' in eventParts: eventParts.remove('')
					sample = int(eventParts[0])
					code = int(eventParts[3])
					comments = ' '.join(eventParts[4:])
					# Add initial offset to each row
					sample = sample + offset
					# Write event file
					outEvent = '\t{:d}\t{:.3f}\t0\t{:d}'.format(sample, sample/1000.0, code)
					outfile.write(outEvent + '\n')
		
