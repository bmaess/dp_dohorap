#!/usr/bin/python
#thicken_grey.py

import getopt, sys
from scipy import ndimage
import nibabel as nib
from numpy import logical_or
from numpy import logical_and

def usage():
      print "\nThis is the usage function\n"
      print 'Usage: '+sys.argv[0]+' -i inputfile -o outputfile'

def thicken_grey( img ):
	grey = 1
	white = 2
	#brain = logical_or((img.get_data() == grey), (img.get_data() == white));
	cortex = img.get_data() == grey
	# Calculate the distance of each voxel to the surface of the brain
	d = ndimage.morphology.distance_transform_cdt(cortex, metric='chessboard', return_distances=True, return_indices=False, distances=None, indices=None);
	d_img = nib.Nifti1Image(d*10.0, img.get_affine())
	nib.save(d_img, 'temp.nii')
	# Select the inner border of the brain with a thickness of 4
	temp = logical_and(d<2.5, d>0)
	img.get_data()[temp] = grey;
	return img

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
            img = nib.load(arg)
        elif opt in ("-o", "--output"):
            output = arg
        else:
            assert False, "unhandled option"

    try:
        result = thicken_grey(img)
        nib.save(result, output)
    except NameError:
        print "input or output is not defined correctly!"

if __name__ == "__main__":
    main(sys.argv[1:])

