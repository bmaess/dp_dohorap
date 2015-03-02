#!/usr/bin/python
#write_label.py

import os
from subprocess import call
import sys, getopt
import nibabel as nib
from scipy.io import savemat

opts, args = getopt.getopt(sys.argv[1:], "i:o:h", ["help", "input=", "output="])
  
for opt, arg in opts:
	if opt in ("-i", "--input"):
		inputFileName = arg
	elif opt in ("-o", "--output"):
		outputFileName = arg
	else:
		assert False, "unhandled option"

img       = nib.load(inputFileName)
seg       = img.get_data()[img.get_data()!=0]

label = {}
label['label'] = seg
savemat(outputFileName, label)

