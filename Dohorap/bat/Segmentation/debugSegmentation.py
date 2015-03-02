import argparse
import os, csv
import nibabel
import numpy as np
import scipy
import drlsHelpers

def niftiSave(seg, outfile):
	seg_image = nibabel.Nifti1Image(seg, imgAffine)
	print "Writing " + outfile
	nibabel.save(seg_image, outfile)

# Settings
configVersion = '3'
subject = 'dh55a'

# Paths
batfolder = os.environ['BATDIR']
filename = 't1mprsagADNI32Ch'
outFolder = os.environ['MRIDIR'] + subject + '/Segmented'
outfile = outFolder + '/segmented_drls_1mm_cfg' + configVersion + '.nii'
directory = batfolder + 'Segmentation/'
tissueLabelFileName = batfolder + 'Segmentation/frsv_labelmap.csv'
configfile = directory + configVersion + '.cfg'
aseg = os.environ['SUBJECTS_DIR'] + subject + '/mri/aseg.nii'

# Read config file into the variable cfg
config = open(configfile,'r').readlines()
cfg = dict()
configopts = ['timestep', 'mu', 'iter_inner', 'lambda', 'alfa', 'epsilon', 'c0', 'adaptive', 'sigma', 'border']
for line in config:
	line = line.replace(' ','')
	lineparts = line.split('=')
	if len(lineparts) > 1:
		variablename = lineparts[0]
		variablevalue = lineparts[1].split(';')
		for configopt in configopts:
			if variablename in configopt:
				cfg[configopt] = variablevalue[0]
cfg['directory'] = directory
cfg['batfolder'] = batfolder
dilationBorder = (int(cfg['border']) + int(cfg['iter_inner']))*2 + 1 # enough border to cut off the outer corners

print "Loading TPM"
asegImg = nibabel.load(aseg)
asegAffine = asegImg.get_affine()
# Load the TPMs and extend them with a border
img = nibabel.load(outFolder + '/c1' + filename + '.nii')
seg8 = scipy.io.loadmat(outFolder + '/' + filename + '_seg8.mat')
imgAffine = img.get_affine()
s = [i + 2*dilationBorder for i in img.get_data().shape]
tpm = np.zeros((s[0], s[1], s[2], 6))
backgrounds = [0,0,0,0,0,1]
for i in range(6):
	img = nibabel.load(outFolder + '/c{}'.format(i+1) + filename + '.nii')
	imgData = img.get_data()
	if i == 3:
		imgData = drlsHelpers.cutoffTalairachZ(img, seg8, 71, backgrounds[i])
	imgSmoothed = drlsHelpers.smooth3D(imgData, float(cfg['sigma']))
	tpm[:,:,:,i] = drlsHelpers.expand3D(imgSmoothed, backgrounds[i], dilationBorder)
segML = np.argmax(tpm, 3) + 1
