import subprocess
import os

#f = open('/scr/kuba2/Dohorap/Main/Data/bat/config/subjectIDs.txt','r')
f = open('subjectIDs.txt','r')
data = f.read().split('\n')
f.close()
firstChild = 1
for line in data:
	IDs = line.split(' ')
	if '##' in IDs[0]:
		dataset = IDs[1]
	if len(IDs) >= 2 and not '#' in IDs[0]:
		localID = IDs[1]
		globalID = IDs[0]
		source = '/a/probands/bdb/' + globalID + '/'
		tempsource = '/scr/mrincoming/' + globalID + '/'
		goal = "/SCR/portain/dh" + localID + "a/"
		MRIdate = IDs[3]
		if '.' in MRIdate:
			MRIdate = IDs[3].split('.')
			if dataset == 'Adults':
				suffix = globalID + '_' + MRIdate[2][2:] + MRIdate[1] + MRIdate[0] + '_'
				# print "\n--- Copying adult " + globalID + ' ---'
				entries = os.listdir(source)
				if len(entries) > 0:
					for entry in entries:
						if suffix in entry:
							# print entry
							temp = 3
							# subprocess.call(['rsync','-Cuvrat', source + entry, goal])
					#subprocess.call(["rsync","-Cuvrate","ssh","portain@toronto:" + tempsource + suffix + '*' , goal])
			elif dataset == 'Children':
				tempsource = '/a/tmp/group/mri/incoming_kids/'
				MRIID = IDs[2]
				if '.' in IDs[4]:
					MRIdate = IDs[4].split('.')
					kids = os.listdir(tempsource)
					suffix = MRIdate[2]+MRIdate[1]+MRIdate[0]
					for kid in kids:
						if MRIID == kid[0:4] and suffix in kid:
							print "Copying child " + globalID
							subprocess.call(['cp', '-r', tempsource + kid, goal])
