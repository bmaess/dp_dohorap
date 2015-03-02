import drlsHelpers
import numpy as np
import os
import nibabel

def niftiSave(cfg, seg, outfile):
	seg_image = nibabel.Nifti1Image(seg, cfg['affine'])
	print "Writing " + cfg['directory'] + outfile
	nibabel.save(seg_image, cfg['directory'] + outfile)

def invert(img):
	return np.logical_not(img)

def createSkullLayer(cfg, tpm):
	# Build a rudimentary (filled) skull layer
	outsideTPM = np.sum(tpm[:,:,:,4:6],3)
	insideTPM = np.sum(tpm[:,:,:,0:4],3)
	rawSkull = insideTPM > outsideTPM
	#niftiSave(cfg, rawSkull.astype(int), '2a - rawSkull.nii')

	# Get rid of the central strip of "skin" (actually arteries) inside the skull
	skin = tpm[:,:,:,4] > 0.8 # Build a conservative skin mask
	skullArea = drlsHelpers.dilateBinary(rawSkull, 5) # Select a region around the skull
	skin = np.logical_and(skin, skullArea) # Select only the skull region
	#niftiSave(cfg, skin.astype(int), '2b - skin.nii')
	# Select the central sliver (assumes that the skin on the head is bigger, and connected)
	arterialSkin = drlsHelpers.nthLargest(skin,1) # this should extract our central arteries
	#niftiSave(cfg, arterialSkin.astype(int), '2c - arterialSkin.nii')

	# Build an outer layer to the skull
	generousShell = tpm[:,:,:,3] > 0.2 # generous outer shell
	cleanShell = drlsHelpers.largest(generousShell) # Get rid of small voxels
	airlessShell, shellPockets = drlsHelpers.extractAirPockets(cleanShell) # get rid of air pockets
	#niftiSave(cfg, airlessShell.astype(int), '2d - airlessShell.nii')
	#niftiSave(cfg, shellPockets.astype(int), '2e - shellPockets.nii')

	# Build a completely filled skull compartment
	combinedSkull = np.logical_or(rawSkull, arterialSkin)
	filledSkull = drlsHelpers.fillBinary(combinedSkull, 1) # Fill the worst gaps
	largestSkull = drlsHelpers.largest(filledSkull) # Get rid of small voxels
	airlessSkull, skullPockets = drlsHelpers.extractAirPockets(largestSkull) # Get rid of air pockets
	cleanSkull = drlsHelpers.erodeBinary(airlessSkull,1) # Shrink it a bit
	#niftiSave(cfg, cleanSkull.astype(int), '2f - cleanSkull.nii')
	airlessSkull = np.logical_or(cleanSkull, cleanShell) # Replace the surface with the skull surface data
	#niftiSave(cfg, airlessSkull.astype(int), '2g - airlessSkull.nii')

	cfg['outfile'] = cfg['directory'] + 'drls-skull.mat'
	if not os.path.isfile(cfg['outfile']) and False:
		skullMask = np.sum(tpm[:,:,:,4:6],3) > np.sum(tpm[:,:,:,0:4],3) # 1 for inner skull, 0 for air and skin
		skullLargestCluster = drlsHelpers.clusters.largest(skullMask)
		dilatedSkullMask = dilate3D(skullLargestCluster, iterations=dilationIterations)
		drlsHelpers.computeDRLS(cfg, tissueTPM = skullTPM, dilatedMask = dilatedSkullMask.astype(int), volumeMask = skullLargestCluster.astype(int))
	if os.path.isfile(cfg['outfile']):
		drls = scipy.io.loadmat(cfg['outfile'])

	return airlessSkull, cleanShell, shellPockets, skullPockets
	
