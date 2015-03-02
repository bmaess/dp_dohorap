import scipy.ndimage

def dilateBinary(img, iterations):
	return scipy.ndimage.morphology.binary_dilation(img, iterations=iterations)

def erodeBinary(img, iterations):
	return scipy.ndimage.morphology.binary_erosion(img, iterations=iterations)

def fillBinary(img, iterations):
	return scipy.ndimage.morphology.binary_closing(img, iterations=iterations)

def grindBinary(img, iterations):
	return scipy.ndimage.morphology.binary_opening(img, iterations=iterations)
