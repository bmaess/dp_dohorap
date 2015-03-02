from subprocess import call
from os import mkdir, listdir, getcwd, environ
import sys

batDir = getcwd().split('/')
rootDir = '/'.join(batDir[0:-1])
subjectDir = sys.argv[1]
bestFile = sys.argv[2]
fullSubjectDir = rootDir + '/MRI/' + subjectDir
call(['tar', '-xvzf', fullSubjectDir + '/' + bestFile, '-C', fullSubjectDir + '/'])
DICOMFolder = fullSubjectDir + '/' + bestFile[0:-7]
DICOMFiles = listdir(DICOMFolder)
DICOMNumbers = []
for DICOMFile in DICOMFiles:
	DICOMNumbers.append(int(DICOMFile))
bestFile = DICOMFiles[min(xrange(len(DICOMNumbers)), key=DICOMNumbers.__getitem__)]
call(['recon-all', '-i', DICOMFolder + '/' + bestFile, '-subjid', subjectDir])
call(['rm', '-rf', DICOMFolder])
call(['recon-all', '-autorecon1', '-nuintensitycor-3T', '-subjid', subjectDir])
call(['recon-all', '-autorecon2', '-subjid', subjectDir])
call(['recon-all', '-autorecon3', '-subjid', subjectDir])

