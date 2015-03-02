from multiprocessing import Pool
import subprocess

def startFreesurfer(subject):
	s = 'dh{:02d}a'.format(subject)
	return subprocess.call(['recon-all', '-all', '-s', s, '-nuintensitycor-3T', '-notal-check', '-T2', '/scr/kuba2/Dohorap/Main/Data/MRI/freesurfer/' + s + '/mri/t2/t2.mgz', '-T2pial'])

pool = Pool(10)
subjects = range(4,13) + range(14,17) + range(52,61) + range(62,70) + range(71,72)
feedback = pool.map(startFreesurfer, subjects)
pool.close()
pool.join()
