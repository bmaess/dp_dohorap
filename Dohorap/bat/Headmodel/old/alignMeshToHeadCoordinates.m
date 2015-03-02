function trans_5to4 = alignMeshToHeadCoordinates(corFile)
%addpath('/scr/kuba1/Matlab/fieldtrip_120925/external/mne/');

% Transformation from 4 to 5 (head -> MRI):
cor = fiff_read_mri(corFile);
trans_4to5 = cor.trans.trans;
trans_5to4 = [trans_4to5(1:3,1:3)', -trans_4to5(1:3,1:3)'*trans_4to5(1:3,4); 0 0 0 1]; % invert the first matrix
