import nibabel
import argparse
import os
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

tissues = ['Air', 'Grey matter', 'White matter', 'CSF', 'Bone', 'Soft tissue']
colors = np.array([[0,0,0], [96,96,96], [255,255,255], [0,255,166], [130,0,150], [227,161,115]])

parser = argparse.ArgumentParser(description='Visualize slice from a selected Nifti')
parser.add_argument('-i','--infile',     type=str, help="input filename")
parser.add_argument('-o','--outfile',    type=str, help="output filename")
parser.add_argument('-d','--direction',  type=str, help="slice direction (sagittal, horizontal, coronal)")
parser.add_argument('-c','--colormap',   type=str, help="use the segmentation colormap or not")
args = parser.parse_args()
infile = args.infile
outfile = args.outfile
useColormap = args.colormap
direction = args.direction

img = nibabel.load(infile)
imgData = img.get_data().astype(float)
if useColormap in ['yes','Yes','true','True']:
	colormap = mpl.colors.ListedColormap(colors/255.0)
else:
	colormap = 'bone'
slicenumbers = [i * 16 for i in range(15)]
outfileParts = outfile.split('.png')
for slicenumber in slicenumbers:
	outfile = ''.join(outfileParts) + '{}.png'.format(slicenumber)
	if direction in ['sagittal','saggital','s']:
		niiSlice = np.squeeze(imgData[:,:,slicenumber])
	elif direction in ['horizontal','h']:
		niiSlice = np.squeeze(imgData[slicenumber,:,:])
	elif direction in ['coronal','c']:
		niiSlice = np.squeeze(imgData[:,slicenumber,:])
	plt.imsave(outfile, arr=niiSlice, cmap=colormap)
