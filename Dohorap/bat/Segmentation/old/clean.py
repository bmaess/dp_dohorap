#!/usr/bin/python
#clean.py

import sys
import getopt
from PIL import Image
from nibabel import load, save, Nifti1Image
from numpy import histogram, argmax, logical_and, squeeze, transpose
from scipy import ndimage

def usage():
      print "\nThis is the usage function\n"
      print 'Usage: '+sys.argv[0]+' -i inputfile -o outputfile'

def clean( img ):
    global filecount
    filecount = 0
    def imsave(matrix, filename):
        global filecount
        #matrix = transpose(matrix, (1,2,0))
        xmax,ymax,zmax = matrix.shape
        imslice = squeeze(matrix[:,:,round(0.54*zmax)])
        im = Image.new('L', (xmax,ymax))
        largestPixel = max(imslice.flatten())
        smallestPixel = min(imslice.flatten())
        if largestPixel == smallestPixel:
            scalingFactor = 255.0/largestPixel
        if largestPixel == 0:
            scalingFactor = 0
        scalingFactor = 255.0/(largestPixel-smallestPixel)
        imslice = (imslice - smallestPixel)*scalingFactor
        filecount += 1
        for x in xrange(xmax):
           for y in xrange(ymax):
               thisPixel = imslice[x,(ymax-1)-y]
               if isnan(thisPixel):
                    thisPixel = 0
               im.putpixel((x,y),(thisPixel))
        im.save('/SCR2/Dohorap/Main/Data/' + '{:02d}'.format(filecount) + '_' + filename + '.png')
    
    'Clean the raw segmentation.'

#    z_cut = 40
#    y_cut = -90
#    [x, y, z] = nonzero(img.get_data() + 1)
#    vert = dot(img.get_affine(), [x, y, z, ones(z.shape)])
#    mask_cut = img.get_data().flatten() + 1
#    mask_cut[vert[2, :] < z_cut] = 0
#    mask_cut[vert[1, :] < y_cut] = 0

    # Skull segmentation
    orig_skull = (img.get_data() == 3).astype(int)
    imsave(orig_skull, 'orig_skull')
    # remove everything except the largest compartment
    labeled, n = ndimage.measurements.label(orig_skull)
    hist,bin_edges = histogram(labeled, n+1)
    v = argmax(hist)
    hist[v] = 0
    v = argmax(hist)
    one_skull = (labeled == v).astype(int)
    imsave(one_skull, 'one_skull')
	# fill noisy non-skull voxels with skull (up to a depth of 4)
    close_skull = ndimage.morphology.binary_closing(one_skull, iterations=4).astype(int)
    imsave(close_skull, 'close_skull')
    # remove holes smaller than the sinuses (ideally)
    labeled, n = ndimage.measurements.label((close_skull==0).astype(int))
    hist,bin_edges = histogram(labeled, n + 1)
    v = argmax(hist)
    clean_skull = 1 - (labeled == v).astype(int)
    imsave(clean_skull, 'clean_skull')

    # Skin segmentation
    orig_skin = (img.get_data() == 4).astype(int)
    imsave(orig_skin, 'orig_skin')
    # remove tiny patches of floating skin
    erode_skin = ndimage.morphology.binary_erosion(orig_skin, iterations=1).astype(int)
    imsave(erode_skin, 'erode_skin1')
	# remove everything except for the biggest compartment
    labeled, n = ndimage.measurements.label(erode_skin)
    hist,bin_edges = histogram(labeled, n + 1)
    v = argmax(hist)
    hist[v] = 0
    v = argmax(hist)
    one_skin = (labeled == v).astype(int)
    imsave(one_skin, 'one_skin1')
				
    # correct for the initial erosion
    one_skin = ndimage.morphology.binary_dilation(one_skin, iterations=1).astype(int)
    imsave(one_skin, 'one_skin2')
    close_skin = ndimage.morphology.binary_closing(one_skin, iterations=3).astype(int)
    imsave(close_skin, 'close_skin')

    # fill in small holes in the skin
    labeled, n = ndimage.measurements.label((close_skin==0).astype(int))
    hist,bin_edges = histogram(labeled, n + 1)
    v = argmax(hist)
    clean_skin = 1 - (labeled == v).astype(int)
    imsave(clean_skin, 'clean_skin1')

    # fill in the non-skin details to make sure that there's no air between skull and skin
    skinskull = clean_skin + clean_skull
    imsave(skinskull, 'skinskull')
    labeled, n = ndimage.measurements.label((skinskull==0).astype(int))
    imsave(labeled, 'skinskull_labeled')
    hist,bin_edges = histogram(labeled, n + 1)
    v = argmax(hist)
    hist[v] = 0
#    v2 = argmax(hist)
#    hist[v2] = 0
#    v3 = argmax(hist)
    add_skin = 1 - (labeled == v).astype(int) #- (labeled == v2).astype(int) - (labeled == v3).astype(int)
    imsave(add_skin, 'add_skin')
    clean_skin = clean_skin + add_skin
    imsave(clean_skin, 'clean_skin2')

    seg = (clean_skin != 0).astype(int)
    imsave(seg, 'seg1')
    seg[clean_skull==1] = 2
    imsave(seg, 'seg2')

    orig_csf = (img.get_data() == 2).astype(int)
    imsave(orig_csf, 'orig_csf')
    erode_csf = orig_csf
#    erode_csf = ndimage.morphology.binary_erosion(orig_csf,iterations=1).astype(int)
    labeled, n = ndimage.measurements.label(erode_csf)
    imsave(labeled, 'csf_labeled')
    hist, bin_edges = histogram(labeled, n + 1)
    v = argmax(hist)
    hist[v] = 0
    v = argmax(hist)
    one_csf = (labeled == v).astype(int)
    imsave(one_csf, 'one_csf1')
    one_csf = ndimage.morphology.binary_dilation(one_csf,iterations=1).astype(int)
    imsave(one_csf, 'one_csf2')
    mask_csf = (seg==0) - (img.get_data()==0) - (img.get_data()==1)
    imsave(mask_csf, 'mask_csf')
    csf = ndimage.binary_dilation(one_csf, iterations=0, mask=mask_csf)
    imsave(csf, 'csf')
    seg[csf==1] = 3
    imsave(seg, 'seg3')

    orig_white = (img.get_data() == 1)
    imsave(orig_white, 'orig_white')
    s = ndimage.generate_binary_structure(3,3)
    labeled, n = ndimage.measurements.label(orig_white, structure=s)
    hist, bin_edges = histogram(labeled, n + 1)
    v = argmax(hist)
    hist[v] = 0
    v = argmax(hist)
    one_white = (labeled == v).astype(int)
    mask_white = (seg==0) - (img.get_data()==0)
    imsave(one_white, 'one_white')
    white = ndimage.binary_dilation(one_white, iterations=0, mask=mask_white)
    imsave(white, 'white')
    seg[white==1] = 5
    imsave(seg, 'seg4')

    orig_grey = (img.get_data() == 0).astype(int)
    imsave(orig_grey, 'orig_grey')
    mask_grey = (seg==0)
    imsave(mask_grey, 'mask_grey')
    grey = ndimage.binary_dilation(orig_grey, iterations=0, mask=mask_grey)
    imsave(grey, 'grey')
    seg[grey==1] = 4
    imsave(seg, 'seg5')

    labeled, n = ndimage.measurements.label(seg==0)
    imsave(labeled, 'background_labeled')
    hist, bin_edges = histogram(labeled, n + 1)
    v1 = argmax(hist)
    hist[v1] = 0
    v2 = argmax(hist)
    seg[logical_and((labeled != v1), (labeled != v2))] = 4
    imsave(seg, 'seg6')

    new_image = Nifti1Image(seg, img.get_affine())
    return new_image

def main(argv):
    try:
        opts, args = getopt.getopt(argv, "i:o:dh", ["help", "input=", "output="])
    except getopt.GetoptError as err:          
        # print help information and exit:
        print(err) # will print something like "option -a not recognized"
        usage()                         
        sys.exit(2)                     
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()                     
            sys.exit()                  
        elif opt == '-d':
            global _debug               
            _debug = 1                  
        elif opt in ("-i", "--input"):
            #mridir = os.path.join(os.environ.get('EXPDIR'), '7t')
            img = load(arg)
        elif opt in ("-o", "--output"):
            output = arg
        else:
            assert False, "unhandled option"

    result = clean(img)
    try:
        save(result, output)
    except NameError:
        print "input or output is not defined correctly!"

if __name__ == "__main__":
    main(sys.argv[1:])

