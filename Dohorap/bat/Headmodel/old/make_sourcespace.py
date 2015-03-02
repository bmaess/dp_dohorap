#!/usr/bin/python
#make_sourcespace.py

import os
import nibabel as nib
import sys, getopt
from numpy import ones
from numpy import argwhere
from numpy import squeeze
from nibabel import load, save, Nifti1Image
from scipy import ndimage
from scipy.io import loadmat
from scipy.io import savemat
from boundary import boundary

expdir = os.environ.get('EXPDIR')
batdir = os.environ.get('BATDIR')

opts, args = getopt.getopt(sys.argv[1:], "m:s:o:i:", ["help", "mesh=", "segmentation=", "output=", "ID="])
for opt, arg in opts:
	if opt in ("-m", "--mesh"):
		mesh = loadmat(arg)
	elif opt in ("-s", "--segmentation"):
		img = nib.load(arg)
	elif opt in ("-o", "--output"):
		outputFileName = arg
	else:
		assert False, "unhandled option"

mask_cortex = img.get_data() == 1
mask_venant = ndimage.morphology.binary_erosion(mask_cortex, structure=ones((3,3,3)), iterations=2)
cortex_image = Nifti1Image(mask_venant.astype(int), img.get_affine())
cortexFileName = outputFileName.replace('.mat', '.nii')
save(cortex_image, cortexFileName)
img.get_data()[mask_venant] = 7
label       = img.get_data()[img.get_data()!=0]
elem        = mesh['elem']

[bnd, face, index] = boundary(mesh['vert'], elem[squeeze(argwhere(label==7)), :])

dip = {}
dip['vert'] = bnd
dip['filename'] = 'cortex.dip'
savemat(outputFileName, dip)

