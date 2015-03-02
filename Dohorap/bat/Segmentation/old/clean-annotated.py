#!/usr/bin/python
#clean.py

import sys
import getopt
from nibabel import load, save, Nifti1Image
from numpy import histogram, argsort, logical_and
from scipy import ndimage

def usage():
      print "\nThis is the usage function\n"
      print 'Usage: '+sys.argv[0]+' -i inputfile -o outputfile'

def clean( raw_image ):

	def selectVoxels(image, tissue):
		return (image == tissue).astype(int)
	
	def selectAllVoxelsExcept(image, tissue):
		return (image != tissue).astype(int)
	
	def closeCompartment(image, i):
		return ndimage.morphology.binary_closing(image, iterations=i).astype(int)
	
	def erodeCompartment(image, i):
		return ndimage.morphology.binary_erosion(image, iterations=i).astype(int)
		
	def dilateCompartment(image, i):
		return ndimage.morphology.binary_dilation(image, iterations=i).astype(int)
		
	def maskedDilateCompartment(image, mask):
		return ndimage.binary_dilation(image, iterations=0, mask = mask)
	
	def labeledBiggestFeatures(image, size):
		labeled, n = ndimage.measurements.label(image)
		hist, _ = histogram(labeled, n + 1)
		smallestEntries = argsort(hist)
		v = smallestEntries[-size]
		return labeled, v
		
	def extractBackground(image):
		return selectNthLargestFeature(selectVoxels(image, 0), 0)
		
	def selectNthLargestFeature(image, size, structure=None):
		labeled, v = labeledBiggestFeatures(image, size)
		return selectVoxels(labeled, v)
	

#    z_cut = 40
#    y_cut = -90
#    [x, y, z] = nonzero(rawImage.get_data() + 1)
#    vert = dot(rawImage.get_affine(), [x, y, z, ones(z.shape)])
#    mask_cut = rawImage.get_data().flatten() + 1
#    mask_cut[vert[2, :] < z_cut] = 0
#    mask_cut[vert[1, :] < y_cut] = 0

	# Extract original layers
	img = raw_image.get_data()
	orig_grey = selectVoxels(img, tissue=0)
	orig_white = selectVoxels(img, tissue=1)
	orig_csf = selectVoxels(img, tissue=2)
	orig_skull = selectVoxels(img, tissue=3)
	orig_skin = selectVoxels(img, tissue=4)
	
	# Skull segmentation
	one_skull = selectNthLargestFeature(orig_skull, 1)
	close_skull = closeCompartment(one_skull, 4) # close small holes up to 4 voxels
	clean_skull = 1 - extractBackground(close_skull)
	
	# Skin segmentation
	eroded_skin = erodeCompartment(orig_skin, 1)
	one_skin = selectNthLargestFeature(eroded_skin, 1)
	one_skin = dilateCompartment(one_skin, 1)
	close_skin = closeCompartment(one_skin, 3)
	clean_skin = 1 - extractBackground(close_skin)
	
	skinskull = clean_skin + clean_skull
	add_skin = 1 - extractBackground(skinskull)
	clean_skin = clean_skin + add_skin
	seg = selectAllVoxelsExcept(clean_skin, 0)
	seg[clean_skull==1] = 2
	
	# CSF segmentation
	erode_csf = erodeCompartment(orig_csf, 1)
	one_csf = selectNthLargestFeature(erode_csf, 1)
	one_csf = dilateCompartment(one_csf, 1)
	mask_csf = (seg==0) - orig_grey - orig_white
	csf = maskedDilateCompartment(one_csf, mask_csf)
	seg[csf==1] = 3
	
	# White matter segmentation
	s = ndimage.generate_binary_structure(3,3)
	largest_white = selectNthLargestFeature(orig_white, 1, s)
	mask_white = (seg==0) - selectVoxels(img,0)
	white = maskedDilateCompartment(largest_white, mask_white)
	seg[white==1] = 5
	
	# Grey matter segmentation
	mask_grey = (seg==0)
	grey = maskedDilateCompartment(orig_grey, mask_grey)
	seg[grey==1] = 4
	labeled = selectNthLargestFeature(seg==0, 0)
	v1 = selectNthLargestFeature(labeled, 0)
	v2 = selectNthLargestFeature(labeled, 1)
	seg[logical_and((labeled != v1), (labeled != v2))] = 4
	
	new_image = Nifti1Image(seg, raw_image.get_affine())
	return new_image

def main(argv):
    try:
        opts, args = getopt.getopt(argv, "i:o:dh", ["help", "input=", "output="])
    except getopt.GetoptError as err:          
        # print help information and exit:
        print(err) # will print something like "option -a not recognized"
        usage()                         
        sys.exit(2)                     
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()                     
            sys.exit()                  
        elif opt == '-d':
            global _debug               
            _debug = 1                  
        elif opt in ("-i", "--input"):
            #mridir = os.path.join(os.environ.get('EXPDIR'), '7t')
            rawImage = load(arg)
        elif opt in ("-o", "--output"):
            output = arg
        else:
            assert False, "unhandled option"

    result = clean(rawImage)
    try:
        save(result, output)
    except NameError:
        print "input or output is not defined correctly!"

if __name__ == "__main__":
    main(sys.argv[1:])

