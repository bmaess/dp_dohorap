# DWI unwarping with the Ruthotto method
# requires the epiPhaseEnc folder (coded by Riccardo Cafiero)

import os, subprocess
from datetime import datetime
MRIpath = '/scr/kuba1/Dohorap/Main/Data/MRI/'
fileblurbs = 'ep2dDTIstandard32C'

def determineContent(filestem):
	i = 0
	validDataset = -1
	for fileblurb in fileblurbs:
		if fileblurb in filestem:
			validDataset = i
		i += 1
	return (validDataset)

if os.access('/usr/lib/fsl/5.0/flirt', os.X_OK):
#	subjects = ['dh52a','dh02a']
	subjects = os.listdir(MRIpath)
	subjectcount = len(subjects)
	i = 1
	firstSubject = 1
	for subject in subjects:
		if subject[0:2] == 'dh' and '.' not in subject:
			filepath = MRIpath + subject + '/DWI'
			subpath = filepath + '/single'
			MRIfiles = os.listdir(filepath)
			errorcount = 0
			if not os.path.exists(filepath + '/ep2dDTIstandard32Ch.nii.gz'):
				print 'Processing ' + subject + '...'

				# Create a temporary subdirectory
				os.chdir(filepath)
				if os.path.isdir(subpath) and os.path.exists(subpath):
					print 'Working directory already exists for ' + subject + ', cleaning up...'
					subprocess.call(['rm', '-rf', 'single'])
				subprocess.call(['mkdir', 'single'])

				availableDirections = 0
				for MRIfile in MRIfiles:
					validDataset = -1
					filename = MRIfile.split('.')
					if len(filename) == 2:
						if filename[1] == 'nii':
							validDataset = determineContent(filename[0])

					if validDataset != -1:
						direction = 0
						if 'AP' in filename[0]:
							direction = 1
							directionName = subject + '_ap-'
						elif 'PA' in filename[0]:
							direction = -1
							directionName = subject + '_pa-'
						if direction != 0:
							print 'Splitting ' + MRIfile + ' into individual images...'
							os.chdir(filepath)
							subprocess.call(['fslsplit', MRIfile, 'single/' + directionName])
							os.chdir(subpath)
							gzfiles = os.listdir(subpath)
							for gzfile in gzfiles:
								subprocess.call(['gunzip', '-q', gzfile])
							if os.path.exists(filepath + '/single/' + directionName + '0000.nii'):
								availableDirections += 1
							else:
								print 'Error processing ' + subject + ', ' + directionName + '0000.nii not found (FSLsplit or GUnzip failed?)'
								errorcount += 1
					else:
						if '.nii' in MRIfile:
							print 'Not a valid dataset: ' + subject + '/' + MRIfile
							errorcount += 1
			
				if availableDirections == 2:
				
					# estimate the processing time
					if subjectcount > 1:
						if firstSubject == 1:
							starttime = datetime.now()
							firstSubject = 0
						else:
							restsubjects = subjectcount - i
							processingtime = (datetime.now() - starttime) / i
							resttime = processingtime * restsubjects
							print 'Estimated time of arrival: '
							print datetime.now() + resttime

					os.chdir(subpath)
					print 'Correcting EPI phase distortion artifacts with Matlab...'
					commands = ['cd /scr/kuba1/sw/epiPhaseEnc/', 'EpiPhaseEnc_corr(\'' + subpath + '\')', 'exit']
					subprocess.call(['matlab', '-nodisplay','-r', ';'.join(commands)])
					if os.path.exists(filepath + '/single/' + subject + '_tmp01.nii'):
						subprocess.call('fslmerge -t ../ep2dDTIstandard32Ch.nii *_tmp*', shell = True);
						os.chdir(filepath)
						if os.path.exists(filepath + '/ep2dDTIstandard32Ch.nii.gz'):
							if errorcount == 0:
								print 'Everyting went fine! Cleaning up...'
								subprocess.call(['rm', '-rf', subpath])
							else:
								print 'We have a result! There were some errors, so I\'m leaving the temp directory intact.'
						else:
							print 'Error processing ' + subject + ': ' + 'ep2dDTIStandard32Ch.nii.gz not found (FSLmerge failed?)'
					else:
						print 'Error processing ' + subject + ': ' + subject + '_tmp01.nii not found (Matlab failed?)'
				else:
					print 'Error processing ' + subject + ': ' + 'Failed to find (exactly) two datasets with opposite phase directions.'
			else:
				print 'Skipping ' + subject + ': ' + 'Output file already exists. Delete it to force re-computation.'
		i += 1
else:
	print 'Please start FSL --version 5.0 first!'
