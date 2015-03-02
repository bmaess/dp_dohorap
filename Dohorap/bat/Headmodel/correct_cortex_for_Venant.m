function correct_cortex_for_Venant(modelBatchPath, sourcefile, labelfile, meshfile, newmeshfile, segmentedfile, coregistrationfile)

grey = 1;
outnii = [segmentedfile(1:end-4) '-thickened.nii'];

% load sources
sources = mne_read_source_spaces(sourcefile);
source_verts = vertcat(sources(:).rr); % these are in MRI space

% load voxel mesh
load(meshfile); % loads vert, elem, labels, tensors
% Transform the mesh from 2002 (RAS space) to 4 (Head space)
vert_2002 = vert;
vert_2002(:,4) = 1;
coregistration = fiff_read_mri(coregistrationfile);
vert_5 = vert_2002 * inv(coregistration.ras_trans.trans)';
vert_4 = vert_5 * inv(coregistration.trans.trans)';
vert = vert_4(:,1:3);

% search nearest corner vertices for all sources in our head
sources_in_head_indices = unique(knnsearch(vert, source_verts));
%sources_in_head_verts = head_verts(sources_in_head_indices,:);
% Find all the elements that belong to these corners
source_elements = any(ismember(elem,sources_in_head_indices),2);
% Get all corners of our first round of elements
source_elements_corners = elem(source_elements,:);
% Find all the elements that belong to these corners
neighbor_source_elements = any(ismember(elem, source_elements_corners),2);
% Now we should have all elements that are at most two elements away from our source point - the Venant condition

% Let's set those to grey
labels(neighbor_source_elements) = grey;

% For visualisation purposes, create a new Nifti with the corrected voxels
save(labelfile, 'labels', '-v6');
save(newmeshfile, 'vert', 'elem', 'labels', 'tensors');
system(['python ' modelBatchPath 'writeThickenedLabels.py -l ' labelfile ' -s ' segmentedfile ' -o ' outnii]);
end
