for n in range(6):
    filename = 'c' + str(n+1) + 't1mprsagADNI32Ch.nii'
    c = nib.load(filename)
    smallData = interp.zoom(c.get_data(),1/3.0)
    cs = nib.Nifti1Image(smallData, c.get_affine())
    savefile = 'c' + str(n+1) + 'small.nii'
    nib.save(cs, savefile)
