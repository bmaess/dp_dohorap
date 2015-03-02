function make_segmentation_realistic_3T_orig(subjectPath)
nii1 = load_untouch_nii([subjectPath 'Segmented/c1t1mprsagADNI32Ch.nii']);
nii2 = load_untouch_nii([subjectPath 'Segmented/c2t1mprsagADNI32Ch.nii']);
nii3 = load_untouch_nii([subjectPath 'Segmented/c3t1mprsagADNI32Ch.nii']);
nii4 = load_untouch_nii([subjectPath 'Segmented/c4t1mprsagADNI32Ch.nii']);
nii5 = load_untouch_nii([subjectPath 'Segmented/c5t1mprsagADNI32Ch.nii']);
nii6 = load_untouch_nii([subjectPath 'Segmented/c6t1mprsagADNI32Ch.nii']);

img6 = nii1.img;
img6(:,:,:,2) = nii2.img;
img6(:,:,:,3) = nii3.img;
img6(:,:,:,4) = nii4.img;
img6(:,:,:,5) = nii5.img;
img6(:,:,:,6) = nii6.img;

img = mask(img6);

comp = bwconncomp(img == 4, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 0;

comp = bwconncomp(img == 3, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 1;

comp = bwconncomp(img == 2, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 1;

comp = bwconncomp(img == 1, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 4;

comp = bwconncomp(img == 4, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 5;

comp = bwconncomp(img == 5, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 3;

comp = bwconncomp(img == 3, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 0;

comp = bwconncomp(img == 0, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 5;

comp = bwconncomp(img == 4, 6);
[biggest,idx] = max(cellfun(@numel, comp.PixelIdxList));
comp.PixelIdxList(idx) = [];
img(cat(1,comp.PixelIdxList{:})) = 0;

comp = bwconncomp(img == 0, 6);
comp = bwconncomp(img == 1, 6);
comp = bwconncomp(img == 2, 6);
comp = bwconncomp(img == 3, 6);
comp = bwconncomp(img == 4, 6);
comp = bwconncomp(img == 5, 6);

nii = nii1;
nii.img = img;
save_untouch_nii(nii,[subjectPath 'Segmented/segmentation_clean.nii']);


end