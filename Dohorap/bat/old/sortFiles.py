import os
import shutil
p = '/SCR2/Dohorap/Main/Data/MEG'
s = '_mc'
entries = os.listdir(p + s)
t = []
for e in entries:
	if e[0:2] == 'dh':
		ePath = p + s + '/' + e + '/'
		files = os.listdir(ePath)
		for f in files:
			fn = f
			if s in fn:
				fn = fn.replace(s,'')
			fns = fn.split('_')
			for i, fnsp in enumerate(fns):
				if e in fnsp:
					if len(fnsp) == len(e):
						fns[i] = 'blocks'
					else:
						fns[i] = fnsp.replace(e, 'block')
			fn = '_'.join(fns)
			ef = os.path.join(ePath, f)
			efn = os.path.join(ePath, fn)
			if efn in t:
				print 'Already exists: ', efn
			else:
				t.append(efn)
			print ef, efn
			os.rename(ef, efn)

