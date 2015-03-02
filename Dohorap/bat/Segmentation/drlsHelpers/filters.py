import numpy as np
import scipy.ndimage.filters
import csv

def smooth3D(imgData, sigma):
	if sigma > 0:
		return scipy.ndimage.filters.gaussian_filter(imgData, sigma, mode='constant', cval=0.0)
	else:
		return imgData

def crop3D(imgData, d):
	return imgData[d:-d,d:-d,d:-d]

def expand3D(imgData, background, d):
	larger_img = np.ones(tuple([i+d*2 for i in imgData.shape])) * background
	larger_img[d:-d,d:-d,d:-d] = imgData
	return larger_img	

def cutoffTalairachZ(img, seg8, distance, background):
	affine = np.dot(seg8['Affine'], img.get_affine())
	imgData = img.get_data()
	[x, y, z] = np.nonzero(imgData + 1)
	vert = np.dot(affine, [x, y, z, np.ones(z.shape)])
	mask = imgData.flatten() + 1
	mask[vert[2, :] < -distance] = 0
	imgData.flat[mask < 0.5] = background
	return imgData

def correctFreesurferSeg(asegImg, tissueLabelFileName):
	infile = open(tissueLabelFileName, 'r')
	reader = csv.reader(infile)
	segFS = np.zeros(asegImg.get_data().shape)
	for row in reader:
		if row[1] > 0:
			segFS[asegImg.get_data()==int(row[0])] = int(row[1])
	infile.close()
	return segFS
