from multiprocessing import Pool
import subprocess

def startFreesurfer(s):
	return subprocess.call(['mne_setup_bem.sh', s, '-is', '4', '-iv', '2', '-b', '1'])
	return subprocess.call(['mkheadsurf', '-s', s])
	return subprocess.call(['mne_surf2bem', '--surf', subjectPath + s + '/surf/lh.seghead', '--id', '4', '--check', '--fif', subjectPath + s + '/bem/' + s + '-head.fif'])

def stringify(subjectNumbers):
	return ['dh{:#02d}a'.format(subjectNumber) for subjectNumber in subjectNumbers]

pool = Pool(15)
subjectPath = '/scr/kuba2/Dohorap/Main/Data/MRI/freesurfer/'
subjects = stringify(range(4,13) + range(14,17) + range(52,61) + range(62,70) + range(71,71))
feedback = pool.map(startFreesurfer, subjects)
pool.close()
pool.join()
