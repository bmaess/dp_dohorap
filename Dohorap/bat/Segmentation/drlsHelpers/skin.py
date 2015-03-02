import drlsHelpers
import scipy
import numpy as np
import os

def invert(img):
	return np.logical_not(img)

def normalize(a):
	lower = np.min(a)
	upper = np.max(a)
	value = upper - lower
	return (a-lower)/value

def createSkinLayer(cfg, tpm):

	# Create a few helper TPMs
	airTPM = tpm[:,:,:,5]
	headTPM = np.sum(tpm[:,:,:,0:5],3)
	headMask = headTPM > airTPM

	print "Cleaning skin layer..."
	# Remove obvious artifacts
	largestCluster = drlsHelpers.largest(headMask)

	# Remove less obvious artifacts
	erodedLargestHead = drlsHelpers.erodeBinary(largestCluster,1) # Remove attached single voxel noise (makes the head smaller by 1)
	air = invert(erodedLargestHead) # Get the air around the head (air is 1 voxel too large)
	largestAirCluster = drlsHelpers.nthLargest(air,-1) # Get rid of air pockets in the skull
	air = drlsHelpers.fillBinary(largestAirCluster,1) # Get rid of unattatched single non-air voxels
	air = drlsHelpers.erodeBinary(air,1) # Correct the air size
	head = invert(air) # recover head from surrounding air
	cleanHead = drlsHelpers.largest(head) # remove all free-floating (large) artifacts

	# Create a filled head for the volume estimation
	head = drlsHelpers.fillBinary(cleanHead,5) # try to fill small gaps for a better volume estimation
	air = invert(head)
	air = drlsHelpers.nthLargest(air,-1) # Get rid of all remaining air pockets
	filledHead = invert(air) # filled head with a semi-smooth surface

	# Recover air pockets
	head = np.logical_and(largestCluster, filledHead) # create a filled head with air pockets
	airPockets = np.logical_xor(head, filledHead) # Extract the air pockets from the head

	# Run DRLS for a smoother head surface
	cfg['outfile'] = cfg['directory'] + 'drls-skin.mat'
	if not os.path.isfile(cfg['outfile']) and False:
		# Dilate the skin surface by a few voxels to prevent cave-ins during DRLS
		iterations = int(cfg['iter_inner']) + 1
		dilatedSkin = drlsHelpers.dilateBinary(filledHead,iterations)

		# Clean up the TPM
		skinTPM = normalize(headTPM - airTPM)
		skinTPM = (skinTPM * 255).astype(int) # convert from floats to integers
		skinTPM[invert(filledHead)] = 0 # Cut away all stray voxels

		# Invoke Matlab
		drlsHelpers.computeDRLS(cfg, tissueTPM = skinTPM, dilatedMask = dilatedSkin.astype(int), volumeMask = filledHead.astype(int))

	if not os.path.isfile(cfg['outfile']):
		print 'DRLS computation failed. Falling back to morphological head surface.'
		drls = cleanHead
	else:
		drls = scipy.io.loadmat(cfg['outfile'])
		drls = drls > 0.0

		# Check if the DRLS succeded or if it caved in
		volumeChange = np.sum(drls) / np.sum(filledHead)
		if volumeChange > 1.01 or volumeChange < 0.95:
			print 'DRLS computation failed: result has a relative volume of {:.0f}%. Falling back to morphological head surface.'.format(100*(volumeChange-1))
			drls = cleanHead

	# Re-insert all the internal air compartments
	headMask = np.logical_and(invert(airPockets), drls)

	return headMask
