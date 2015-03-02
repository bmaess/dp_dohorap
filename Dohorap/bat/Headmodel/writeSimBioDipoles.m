function writeSimBioDipoles(freesurferSourceFile, dipoleFile, dipoleCount, coregistrationfile)
sources = mne_read_source_spaces(freesurferSourceFile);
coregistration = fiff_read_mri(coregistrationfile);
sourceVerts = vertcat(sources(:).rr); % these are in MRI space (5)
% Transform sourceVerts to Head space (4)
vert_5 = sourceVerts;
vert_5(:,4) = 1;
vert_4 = vert_5 * inv(coregistration.trans.trans)';
sourceVerts = vert_4(:,1:3);

% Draw a random sample of size dipoleCount from the available dipoles
sourceIndices = 1:size(sourceVerts,1);
if dipoleCount > 0
    sampleIndices = randsample(sourceIndices, dipoleCount);
    sampleVerts = sourceVerts(sampleIndices,:);
else
    sampleVerts = sourceVerts;
end;

sb_write_dip(sampleVerts, dipoleFile);
end
