import scipy.ndimage

def dilateGrey(img, i):
	return scipy.ndimage.morphology.grey_dilation(img, size=(i,i))

def erodeGrey(img, i):
	return scipy.ndimage.morphology.grey_erosion(img, size=(i,i))

def fillGrey(img, i):
	return scipy.ndimage.morphology.grey_closing(img, size=(i,i))

def grindGrey(img, i):
	return scipy.ndimage.morphology.grey_opening(img, size=(i,i))
