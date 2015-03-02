#!/usr/bin/python
#drls_segment.py

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
dilationIterations = 3 # distance between the surface of skull/skin and the initial levelset
batfolder = os.environ['BATDIR']
innerSkullSampling = 'Freesurfer' # ML or Freesurfer
skullLayerSampling = 'DRLS' # ML or DRLS
skinLayerSampling = 'DRLS' # ML or DRLS

# Parse arguments
parser = argparse.ArgumentParser(description='Prepare SPM segmentation for levelset functions')
parser.add_argument('-i','--infile',    type=str, help="input filename")
parser.add_argument('-a','--aseg',      type=str, help="Freesurfer segmentation")
parser.add_argument('-o','--outfile',   type=str, help="output filename")
parser.add_argument('-c','--config',    type=str, help="config filename")
parser.add_argument('-d','--directory', type=str, help="Directory for the SPM results")
args = parser.parse_args()
filename  = args.infile
outfile   = args.outfile
directory = args.directory + '/'
tissueLabelFileName = batfolder + 'Segmentation/frsv_labelmap.csv'
configfile= args.config
aseg      = args.aseg

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
dilationBorder = (dilationIterations + int(cfg['iter_inner']))*2 + 1 # enough border to cut off the outer corners

print "Loading TPM"
asegImg = nibabel.load(aseg)
asegAffine = asegImg.get_affine()
# Load the TPMs and extend them with a border
img = nibabel.load(directory + 'c1' + filename + '.nii')
seg8 = scipy.io.loadmat(directory + filename + '_seg8.mat')
imgAffine = img.get_affine()
cfg['affine'] = imgAffine
s = [i + 2*dilationBorder for i in img.get_data().shape]
tpm = np.zeros((s[0], s[1], s[2], 6))
backgrounds = [0,0,0,0,0,1]
for i in range(6):
	img = nibabel.load(directory + 'c{}'.format(i+1) + filename + '.nii')
	imgData = img.get_data()
	if i == 3:
		imgData = drlsHelpers.cutoffTalairachZ(img, seg8, 71, backgrounds[i])
	imgSmoothed = drlsHelpers.smooth3D(imgData, float(cfg['sigma']))
	tpm[:,:,:,i] = drlsHelpers.expand3D(imgSmoothed, backgrounds[i], dilationBorder)

# Create the ML for comparison
segML = np.argmax(tpm, 3) + 1
segMLimg = nibabel.Nifti1Image(segML, img.get_affine())
segMLfile = outfile.replace('.nii', '-ML.nii')
nibabel.save(segMLimg, segMLfile)

# Create the helper layers
filledHead = drlsHelpers.createSkinLayer(cfg, tpm)
niftiSave(filledHead.astype(int), directory + '1 - filledHead.nii')
filledSkull, skullShell, shellPockets, skullPockets = drlsHelpers.createSkullLayer(cfg, tpm)
niftiSave(filledSkull.astype(int), directory + '2 - filledSkull.nii')

# Assemble the head model layers
seg = np.zeros(segMLimg.shape)
if skinLayerSampling == 'DRLS':
	seg[filledHead] = 5
	seg[filledSkull] = 3
	seg[skullPockets] = 3
	seg[skullShell] = 4
	seg[shellPockets] = 0
elif skinLayerSampling == 'ML':
	seg[segML <= 5] = 5
	seg[segML <= 3] = 3
	seg[segML <= 4] = 4
#niftiSave(seg, '11 - seg.nii')

# Replace the CSF with actual brain parts
print "Populating inner skull contents"
seg = drlsHelpers.crop3D(seg, dilationBorder)
niftiSave(seg, directory + '3 - seg.nii')
if innerSkullSampling == 'ML':
	seg[innerskull] = segML[innerskull]
elif innerSkullSampling == 'Freesurfer':
	# Relabel freesurfer segmentation from 41 to 3 tissue categories
	segFS = drlsHelpers.correctFreesurferSeg(asegImg, tissueLabelFileName)
	# Freesurfer: 1 - white, 2 - grey, 3 - CSF
	# SPM: 0 - grey, 1 - white, 2 - CSF
	spm2fs = [2,1,3]
	for spmLayer in [1,2,3]:
		FSlayer = spm2fs[spmLayer-1]
		seg[segFS == FSlayer] = spmLayer

niftiSave(seg, directory + '4 - seg.nii')
seg_image = nibabel.Nifti1Image(seg, asegAffine)
print "Writing " + outfile
nibabel.save(seg_image, outfile)
