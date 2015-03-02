import scipy
import numpy as np

def invert(img):
	return np.logical_not(img)

def largest(img):
	return nthLargest(img, 0)

def nthLargest(img, index):
	labeled, n = scipy.ndimage.measurements.label(img)
	hist,bin_edges = np.histogram(labeled, n + 1)
	v = np.argsort(hist)
	return labeled == v[-(index+2)]

def count(img):
	labeled, n = scipy.ndimage.measurements.label(img)
	hist,bin_edges = np.histogram(labeled, n + 1)
	hist.sort()
	return hist

def extractAirPockets(tissue):
	air = np.logical_not(tissue)
	air = nthLargest(air,-1)
	airfree = np.logical_not(air)
	pockets = np.logical_xor(tissue, airfree)
	return airfree, pockets
