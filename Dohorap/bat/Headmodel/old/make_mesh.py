#!/usr/bin/python
#make_mesh.py
import getopt, sys
import nibabel as nib
from numpy import ones
from numpy import transpose
from numpy import concatenate
from numpy import dot
from scipy.io import savemat
import mesh

def usage():
	print "\nThis is the usage function\n"
	print 'Usage: '+sys.argv[0]+' -i inputfile -o outputfile'

def main(argv):
	try:
		opts, args = getopt.getopt(argv, "i:o:s:h", ["help", "input=", "output=", "subject="])
	except getopt.GetoptError as err:          
		# print help information and exit:
		print(err) # will print something like "option -a not recognized"
		usage()                         
		sys.exit(2)                     
	for opt, arg in opts:
		if opt in ("-h", "--help"):
			usage()                     
			sys.exit()                  
		elif opt in ("-i", "--input"):
			img = nib.load(arg)
		elif opt in ("-o", "--output"):
			outputFileName = arg
		elif opt in ("-s", "--subjectID"):
			subjectID = arg
		else:
			assert False, "unhandled option"

	[vert, elem] = mesh.mesh(img.get_data())
	vert = dot(concatenate((vert, ones((vert.shape[0], 1))), 1), transpose(img.get_affine()))
	a = {}
	a['vert'] = vert
	a['subjectID'] = subjectID
	a['elem'] = elem
	try:
		savemat(outputFileName, a)
	except NameError:
		print "input or output is not defined correctly!"

if __name__ == "__main__":
	main(sys.argv[1:])

