%-----------------------------------------------------------------------
% Job saved on 29-Aug-2013 17:12:54 by cfg_util (rev $Rev: 3034 $)
% spm SPM - SPM12b (5373)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
%matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {'./T1/t1mprsagADNI32Ch.nii,1'};
%matlabbatch{1}.spm.spatial.coreg.estwrite.source = {'./T2/t2spcsagp2iso.nii,1'};
%matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
%matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
%matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
%matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
%matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
%matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
%matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [1 0 0];
%matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
%matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
matlabbatch{1}.spm.spatial.preproc.channel(1).vols = {'./T1/t1mprsagADNI32Ch.nii,1'};
matlabbatch{1}.spm.spatial.preproc.channel(1).biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel(1).biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel(1).write = [1 1];
matlabbatch{1}.spm.spatial.preproc.channel(2).vols = {'./T2/rt2spcsagp2iso.nii,1'};
matlabbatch{1}.spm.spatial.preproc.channel(2).biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel(2).biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel(2).write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {'/scr/kuba1/sw/spm12b/tpm/TPM_clean.nii,1'};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {'/scr/kuba1/sw/spm12b/tpm/TPM_clean.nii,2'};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {'/scr/kuba1/sw/spm12b/tpm/TPM_clean.nii,3'};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {'/scr/kuba1/sw/spm12b/tpm/TPM_clean.nii,4'};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {'/scr/kuba1/sw/spm12b/tpm/TPM_clean.nii,5'};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {'/scr/kuba1/sw/spm12b/tpm/TPM_clean.nii,6'};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 5;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {'./'};
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'Segmented';
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.files = {
                                                                './T1/BiasField_t1mprsagADNI32Ch.nii'
                                                                './T1/BiasField_rt2spcsagp2iso.nii'
                                                                './T1/c1t1mprsagADNI32Ch.nii'
                                                                './T1/c2t1mprsagADNI32Ch.nii'
                                                                './T1/c3t1mprsagADNI32Ch.nii'
                                                                './T1/c4t1mprsagADNI32Ch.nii'
                                                                './T1/c5t1mprsagADNI32Ch.nii'
                                                                './T1/c6t1mprsagADNI32Ch.nii'
                                                                './T1/mt1mprsagADNI32Ch.nii'
                                                                './T1/mrt2spcsagp2iso.nii'
                                                                './T1/t1mprsagADNI32Ch_seg8.mat'
                                                                './T1/rt2spcsagp2iso_seg8.mat'
                                                                };
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {'./Segmented'};
