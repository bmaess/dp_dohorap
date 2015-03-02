import argparse
from scipy.io import loadmat, savemat
from nibabel import load, save, Nifti1Image

parser = argparse.ArgumentParser(description='Convert segmentation into a Vista mesh')
parser.add_argument('-l','--labelfile',	 type=str, help="Labelfile")
parser.add_argument('-s','--segmentation', type=str, help="Segmentation")
parser.add_argument('-o','--outfile',      type=str, help="output filename")
args = parser.parse_args()
outfile = args.outfile
labelfilename = args.labelfile
segfilename = args.segmentation

labelfile = loadmat(labelfilename)
labels = labelfile['labels']

segImg = load(segfilename)
seg = segImg.get_data().astype(int)
#print seg[seg>0].shape, labels.squeeze().shape
seg[seg>0] = labels.squeeze()
newImg = Nifti1Image(seg, segImg.get_affine())
save(newImg, outfile)
