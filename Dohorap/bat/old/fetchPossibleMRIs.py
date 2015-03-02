from __future__ import division
from subprocess import call
from os import mkdir, listdir, path

origin = '../MEG/'
goal = '../MRI/'
mrtNames = [['t1','mpr','sag','adni','32ch'],['t2','spc','sag','p2','iso'],['ep2d','dti','standard','32ch'],['ep2d','dti','standard','32ch','pa']]
goalDirs = listdir(goal)
originDirs = listdir(origin)
for originDir in originDirs:
	print 'Processsing ' + originDir + ':'
	if originDir[0:2] == 'dh':
		if not originDir in goalDirs:
			mkdir(goal + originDir)
		originFiles = listdir(origin + originDir)
		for originFile in originFiles:
			validFile = 0
			# MEG data
			if originFile[-3:] in ['fif','log']:
				validFile = 1
				goalfile = originFile
			# MRT data
			goalfiles = []
			if originFile[-3:] in ['.gz']:
				for mrttype in mrtNames:
					mrtcount = 0
					for mrt in mrttype:
						if mrt in originFile.lower():
							mrtcount += 1
						else:
							mrtcount -= 1
					# use fuzzy logic to guess the correct dataset
					correctness = mrtcount / len(mrttype)
					if correctness > 0.2:
						validFile = 1
					goalfiles.append(correctness)
				if len(goalfiles) > 0:
					namepool = mrtNames[goalfiles.index(max(goalfiles))]
					if namepool[0] in originFile:
						startpoint = originFile.index(namepool[0])
						goalfile = originFile[startpoint:]
					else:
						validFile = 0
			if validFile == 1:
				fullOrigin = origin + originDir + '/' + originFile
				fullGoal = goal + originDir + '/' + goalfile
				if not path.isfile(fullGoal):
					print 'ln -s ' + fullOrigin + ' ' + fullGoal
					call(['ln','-s',fullOrigin, fullGoal])
				else:
					print 'Skipping ' + fullGoal + ' (already exists)'
