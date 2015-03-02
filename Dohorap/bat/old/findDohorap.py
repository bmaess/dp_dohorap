from subprocess import call
from os import mkdir, listdir, path

print('Looking for your project folder...')
call(['tokenmgr', '-l'])
dirs = listdir('/a/projects')
print ('Step 1: weak search')
searchterms = ['dohorap', 'sam-001', 'sam_001']
found = 0
foundterm = ''
for searchterm in searchterms:
	for dirtydir in dirs:
		d = dirtydir.lower()
		if searchterm in d:
			foundterm = searchterm
if foundterm == '':
	print ('Step 2: strong search')
	searchterms = ['dohorap', 'doho', 'meg', 'sam', '001']
	weights = [10,3,1.5,1.2,0.8]
	dirresult = []
	for dirtydir in dirs:
		d = dirtydir.lower()
		searchresult = []
		for searchterm in searchterms:
			result = 0
			if searchterm in d:
				result = (weights[searchterms.index(searchterm)] * len(searchterm)) / len(d)
			searchresult.append(result)
		dirresult.append(sum(searchresult))
		if sum(searchresult) > 1:
			print ('Likely candidate: ' + d)
