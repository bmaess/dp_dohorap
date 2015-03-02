function segmentedTissues = combineTissueLayers(tissueFolder, fileSuffix, layerCount)
% example: combineTissueLayers('/SCR/seg/SPM/cleanT1', 'T1.nii')
c = load_untouch_nii([tissueFolder, '/c1', fileSuffix]);
tissueProbabilities = zeros([size(c.img), layerCount+1]);
for t = 1:layerCount
    c = load_untouch_nii([tissueFolder, '/c', num2str(t), fileSuffix]);
    tissueProbabilities(:,:,:,t) = c.img;
end;
tissueProbabilities(:,:,:,6) = 255 - sum(tissueProbabilities,4);
segmentedTissues = squeeze(max(tissueProbabilities,4));
c.img = segmentedTissues;
save_untouch_nii(c, [tissueFolder, '/', 'segmented.nii']);
end

