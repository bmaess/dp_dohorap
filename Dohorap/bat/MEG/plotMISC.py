import mne, os
import numpy as np
import matplotlib.pylab as pl
import rstyle

def calculateEvoked (subjectID):
	subject = 'dh{:#02d}a'.format(subjectID)
	outDir = os.environ['DATDIR'] + 'MEG_mc_hp004_ica_l50/' + subject
	docDir = os.environ['DOCDIR'] + 'misc'
	if not os.path.isdir(docDir):
		os.makedirs(docDir)
	pl.clf()
	ax = pl.gca()
	docFilename = '{}/{}.png'.format(docDir, subject)
	for cond in conds:
		evokedFilename = '{}/{}_average-ave.fif'.format(outDir, cond)
		print evokedFilename
		evoked = mne.Evoked(fname=evokedFilename, condition=0, baseline=None, kind='average', verbose=False)
		misc = evoked.data[309,:]
		pl.plot(evoked.times, misc, label=cond)
	ax.set_xlim(xlims)
	pl.legend(loc=1)
	pl.savefig(docFilename, dpi=150, overwrite=True)

	pl.clf()
	ax = pl.gca()
	ax.set_ylim([0, 0.25])
	ax.set_xlim(xlims)
	docFilename = '{}/{}-{}.png'.format(docDir, subject, 'smooth')
	for cond in conds:
		condColor = colors[cond]
		evokedFilename = '{}/{}-epo.fif'.format(outDir, cond)
		print evokedFilename
		epochs = mne.read_epochs(fname=evokedFilename)
		for i in range(len(epochs)):
			misc = np.squeeze(epochs[i].get_data()[0,309,:])
			pl.plot(epochs.times, misc, label=cond, color=condColor, linewidth=0.008, alpha=0)
			ax.fill_between(epochs.times, 0, misc, color=condColor, alpha=0.005, linewidth=0)
	pl.savefig(docFilename, dpi=200, overwrite=True)

conds = ['Vis', 'Feed']
colors = {'Vis':'#0000FF', 'Feed':'#00A000'}
subjectIDs = range(2,20) + range(52,72)
xlims = [-0.5, 1.0]
for subjectID in subjectIDs:
	calculateEvoked(subjectID)
