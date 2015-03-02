from __future__ import division
import mne, os
import numpy as np
import signal, time
from multiprocessing import Pool

def initWorker():
	signal.signal(signal.SIGINT, signal.SIG_IGN)

def loadBads(fName):
	f = open(fName,'r').read().split('\n')
	badChanLibrary = {}
	for line in f:
		if len(line) > 0:
			if line[0] != '#':
				blockParts = {}
				lineparts = line.split(' ')
				lineLength = len(lineparts)
				if lineLength > 2:
					subjectID = int(lineparts[0])
					badChans = []
					if lineparts[2] != '-':
						for i in range(lineLength-2):
							badChan = int(lineparts[i+2])
							badChanString = 'MEG{:#04d}'.format(badChan)
							badChans.append(badChanString)
					if subjectID not in badChanLibrary:
						badChanLibrary[subjectID] = badChans
					else:
						badChanLibrary[subjectID] = list(set(badChanLibrary[subjectID] + badChans))
	return badChanLibrary

def readEvents(eventFilename):
	eventFile = open(eventFilename,'r').read().split('\n')
	events = []
	validTrials = {}
	for rawEvent in eventFile:
		event = [None]*4
		if len(rawEvent) > 0:
			if rawEvent[0] != '#':
				eventParts = rawEvent.split(' ')
				while '' in eventParts:
					eventParts.remove('')
				event[0] = int(eventParts[0]) # sample
				# we're skipping the "time" variable here to simulate a new format event file
				event[1] = int(eventParts[2]) # zero
				event[2] = int(eventParts[3]) # event ID
				currentTrial = int(eventParts[4])
				event[3] = currentTrial
				if currentTrial not in validTrials:
					validTrials[currentTrial] = True
				# introduce a time limit
				if len(eventParts) == 10: # if this line has exactly 10 words
					RT = int(eventParts[8]) # then word #8 must be our RT
					if RT > 4000:
						validTrials[currentTrial] = False
				events.append(event)
	sanitizedEvents = []
	for event in events:
		trial = event[3]
		if not validTrials[trial]:
			event[2] += 1 # mark the trial as invalid. This breaks picture and sentence codes, but for invalid trials only.
		sanitizedEvents.append(event[0:3])
	events = np.array(sanitizedEvents)
	return events

def calculateEvoked (subject):
	# Set parameters
	subjectID = int(subject[2:4])
	eventIDs = {'Vis': 100, 'Obj': 310, 'Subj': 320, 'Feed': 600, 'LeftResp': 610, 'RightResp': 620}
	conds = ['Vis', 'Feed', 'Obj', 'Subj', 'LeftResp', 'RightResp']
	filteringOptions = ['unfiltered', 'filtered']
	tmin = -1.0
	tmax = 4.0
	badChanLibrary = loadBads(os.environ['BATDIR'] + 'config/badChans.txt')
	jumpAmplitudes = dict(grad=400e-12, mag=6e-12)
	outDir = os.environ['DATDIR'] + 'MEG_mc_hp004_ica_l50/' + subject
	if not os.path.isdir(outDir):
		os.makedirs(outDir)
	logFileName = outDir + '/epoching.log'
	logFile = open(logFileName,'w')

	for filteringText in filteringOptions:
		filtering = filteringText == 'filtered'
		averageFile = {}
		epochFile = {}
		stdevFile = {}
		for cond in conds:
			averageFile[cond] = '{}/{}_average-ave.fif'.format(outDir, cond)
			stdevFile[cond] =   '{}/{}_stdev-ave.fif'.format(outDir, cond)
			epochFile[cond] = '{}/{}_{}-epo.fif'.format(outDir, filteringText, cond)
	
		# Load and concatenate files
		# mne.concatenate_events is pretty bad in 0.8.1, so we'll have to merge events for ourselves
		eventsBlock = []
		rawBlock = []
		limits = []
		lastSamps = []
		firstSamps = []
		feedbackEventCountBefore = 0
		for block in [1,2]:
			subjectStub = '{}/block{:d}'.format(subject, block)
			eventFilename = os.environ['DATDIR'] + 'MEG_mc/' + subjectStub + '-eh-derden.eve'
			rawFilename = os.environ['DATDIR'] + 'MEG_mc_hp004_ica/' + subjectStub + '.fif'
			if os.path.exists(eventFilename):
				if os.path.exists(rawFilename):
					# Since MNE has crappy support for different event file formats, let's read it with Python
					#events = mne.read_events(eventFilename)
					events = readEvents(eventFilename)
					logFile.write('\nLoaded {} events from {}:\n'.format(events.shape[0], eventFilename))
					# Recode incorrect visual and feedback events to correct events
					for eventLine in range(events.shape[0]):
						eventID = events[eventLine,2]
						if eventID == 101 or eventID == 601:
							events[eventLine,2] = eventID - 1
					for eventID in eventIDs:
						logFile.write('{:d} {} events\n'.format(np.sum(events[:,2] == eventIDs[eventID]), eventID))
					feedbackEventCountBefore += np.sum(events[:,2] == eventIDs['Feed'])
					# Load the raw files and calculate some helper info
					raw = mne.io.Raw(rawFilename, preload=True)
					raw.info['bads'] = badChanLibrary[subjectID]
					lastSamps.append(raw.last_samp)
					firstSamps.append(raw.first_samp)
					limit = [raw.first_samp, raw.last_samp, raw._raw_lengths[0]]
					# Prepare the concatenation
					eventsBlock.append(events)
					rawBlock.append(raw)
					limits.append(limit)
				else:
					errorText = 'Error: couldn''t find ' + rawFilename + '\n'
					print errorText
					logFile.write(errorText)
			else:
				errorText = 'Error: couldn''t find ' + eventFilename + '\n'
				print errorText
				logFile.write(errorText)

		if len(rawBlock) == 2 and len(eventsBlock) == 2:
			raw = mne.concatenate_raws([rawBlock[0],rawBlock[1]])
			rawBlock = None # save 50% memory with just one line
			logFile.write('Raw file consists of two blocks with lengths {} and {}.\n'.format(raw._raw_lengths[0], raw._raw_lengths[1]))
			# Correct the offsets of the events with Python
			eventsBlock[0][:,0] += limits[0][0]
			eventsBlock[1][:,0] += limits[0][1]
			events = np.concatenate([eventsBlock[0], eventsBlock[1]], axis=0)
		elif len(rawBlock) == 1 and len(eventsBlock) == 1:
			eventsBlock[0][:,0] += limits[0][0]
			events = eventsBlock[0]
			raw = rawBlock[0]
			rawBlock = None

		eventTotalCount = 0
		for eventID in eventIDs:
			eventCount = np.sum(events[:,2] == eventIDs[eventID])
			eventTotalCount += eventCount
			logFile.write('Total events in condition {}: {:d}\n'.format(eventID, eventCount))
		feedbackEventCountAfter = np.sum(events[:,2] == eventIDs['Feed'])
		feedbackEventCountDifference = feedbackEventCountAfter - feedbackEventCountBefore
		if feedbackEventCountDifference != 0:
			warningText = 'Warning: While merging, we lost {:d} Feedback events!\n'.format(feedbackEventCountDifference)
			print(warningText)
			logFile.write(warningText)

		# Filter raw data
		MEG_channels = mne.pick_types(raw.info, meg=True)
		if filtering:
			raw.filter(picks=MEG_channels, l_freq=None, h_freq=20) # MEG_channels

		# Extract epochs
		logFile.write('{:d} interesting events before rejection\n'.format(eventTotalCount))
		epochs = mne.Epochs(raw, events, eventIDs, tmin, tmax, picks=None, baseline=None, reject=jumpAmplitudes, verbose=None, preload=True)
		raw = None
		logFile.write('{:d} interesting events left after rejection\n'.format(len(epochs)))

		print('\nPost-processing subject ' + subject)
		# average epochs and calculate evoked activity
		channelCount = len(epochs.info['chs'])
		allChannels = range(channelCount)
		for cond in conds:
			# save evoked data to disk
			print 'Writing epochs and averages for condition ' + cond
			e = epochs[cond]
			if filtering:
				mne.fiff.write_evokeds(averageFile[cond], e.average(picks=allChannels))
				mne.fiff.write_evokeds(stdevFile[cond], e.standard_error(picks=allChannels))
				if 'Subj' in cond or 'Obj' in cond or 'Vis' in cond:
					e.save(epochFile[cond])
			else:
				if 'Subj' in cond or 'Obj' in cond:
					e.save(epochFile[cond])
			logFile.write('Artifact-free events in condition {}: {:d}\n'.format(cond, len(e)))
	logFile.close()

###############################################################################

def main():
	# Determine individual subject folders
	subjects = []
	dirEntries = os.listdir(os.environ['DATDIR'] + 'MEG_mc_hp004_ica/')
	for dirEntry in dirEntries:
		if len(dirEntry) == 5 and dirEntry[0:2] == 'dh':
			subjects.append(dirEntry)
	subjects.sort()
	multitasking = False
	if multitasking:
		pool = Pool(3, initWorker) # 2 is a good value for eber, 3 fills it completely
		feedback = []
		try:
			for subject in subjects:
				print('Starting subject', subject)
				feedback.append(pool.apply_async(calculateEvoked, (subject, )))
				time.sleep(30) # Delayed onset to reduce disk traffic on kuba
			pool.close()
			while True:
				if all(f.ready() for f in feedback):
					print "All processes completed"
					return
				time.sleep(1)

		except KeyboardInterrupt:
			print "Caught KeyboardInterrupt, terminating workers"
			pool.terminate()
			pool.join()
	else:
		for subject in subjects:
			calculateEvoked(subject)

if __name__ == "__main__":
	main()
