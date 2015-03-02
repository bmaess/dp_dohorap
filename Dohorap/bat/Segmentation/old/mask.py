#!/usr/bin/python
#mask.py
import getopt, sys
import nibabel as nib
import numpy as np

def usage():
      print "\nThis is the usage function\n"
      print 'Usage: '+sys.argv[0]+' -i inputfile -o outputfile'

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
            img = nib.load(arg)
        elif opt in ("-o", "--output"):
            output = arg
        else:
            assert False, "unhandled option"

    try:
        seg = np.argmax(img.get_data(), axis=3)
        new_image = nib.Nifti1Image(seg, img.get_affine())
        nib.save(new_image, output)
    except NameError:
        print "input or output is not defined correctly!"

if __name__ == "__main__":
    main(sys.argv[1:])

