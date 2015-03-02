#!/usr/bin/python
#make_mesh.py
import argparse
import nibabel as nib
import numpy as np
from numpy import ones
from numpy import transpose
from numpy import concatenate
from numpy import dot
from scipy.io import savemat
import mesh
from scipy.io import loadmat, savemat

parser = argparse.ArgumentParser(description='Convert segmentation into a Vista mesh')
parser.add_argument('-s','--segmentation', type=str, help="Segmentation")
parser.add_argument('-c','--conductivity', type=str, help="Conductivity tensor")
parser.add_argument('-o','--outfile',      type=str, help="output filename")
args = parser.parse_args()
outfile = args.outfile

seg = nib.load(args.segmentation)
s = seg.get_data()
FullNonzero = s!=0
FullWhite = s==2
FlatNonzero = np.array(s[FullNonzero])
FlatWhite = np.array(FullWhite[FullNonzero])

cond = np.zeros((len(FlatNonzero), 9))
for i in range(9):
	c = nib.load(args.conductivity + str(i+1) + '.nii')
	cWhiteFull = c.get_data()[FullWhite]
	cond[FlatWhite,i] = cWhiteFull

[vert, elem] = mesh.mesh(FullNonzero)
# Convert mesh from our space to RAS space (2002)
vert = dot(concatenate((vert, ones((vert.shape[0], 1))), 1), transpose(seg.get_affine()))*0.001
a = {}
a['vert'] = vert[:, 0:3]
a['elem'] = elem
a['labels'] = FlatNonzero
a['tensors'] = cond
savemat(outfile, a)
labelfilename = outfile.replace('.mat', '-Venant.mat')
