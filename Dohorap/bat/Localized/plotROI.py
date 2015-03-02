# Copy & paste into pysurfer session (start with "pysurfer dh55a lh pial -background white " in a terminal)

# Change these with every call
hemisphere = 'lh'
surface = 'pial'

expdir = os.environ['EXPDIR']
subjectsDir = os.environ['SUBJECTS_DIR']
docDir = os.environ['DOCDIR']
labelsDir = subjectsDir + 'dh55a/label/Dohorap/'
ROIcolors = [[52,101,243],[83,190,39],[225,39,42],[74,39,139],[157,98,246],[48,112,67],[107,248,155],[221,143,50]]
#                 BA44       BA6v         BA45        aSTG        pSTG         aSTS         pSTS         PAC

# Load labels of interest
labelFileName = subjectsDir + 'a2009s labels.txt'
ROIs = []
labelFile = open(labelFileName,'r').readlines()
for labelLine in labelFile:
	while '\n' in labelLine:
		labelLine = labelLine.replace('\n', '')
	labelParts = labelLine.split(': ')
	ROIs.append(labelParts[1])

# Load the surface
imageFile = docDir + 'ROI/dh55a-' + surface + '-' + hemisphere + '.png'
for ROI, ROIcolor in zip(ROIs, ROIcolors):
	labelFile = labelsDir + hemisphere + '.' + ROI + '.label'
	brain.add_label(labelFile, alpha=.7, color = tuple([r/255.0 for r in ROIcolor]))

brain.save_image(imageFile)
