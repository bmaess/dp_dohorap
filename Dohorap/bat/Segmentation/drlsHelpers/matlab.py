import scipy.io
from subprocess import call

def computeDRLS(cfg, tissueTPM, dilatedMask, volumeMask):
	batfolder = cfg['batfolder']
	mat = {}
	mat['cfg'] = cfg
	mat['tissueTPM'] = tissueTPM
	mat['dilatedMask'] = dilatedMask
	mat['volumeMask'] = volumeMask
	scipy.io.savemat('tmp.mat', mat, oned_as='column')
	print 'Running Matlab with ' + batfolder + '/Segmentation/drls.m'
	call(['matlab', '-nosplash', ' < ' + batfolder + '/Segmentation/drls.m'])
