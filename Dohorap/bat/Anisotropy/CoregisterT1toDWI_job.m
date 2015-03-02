%-----------------------------------------------------------------------
% Job saved on 18-Jun-2013 21:34:54 by cfg_util (rev $Rev: 2911 $)
% spm SPM - SPM12b (5373)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {'./DWI/DistortionCorrected/u0000.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {'./T1/t1mprsagADNI32Ch.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {
                                                   './Segmented/c1t1mprsagADNI32Ch.nii,1'
                                                   './Segmented/c2t1mprsagADNI32Ch.nii,1'
                                                   };
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.files = {
                                                                './T1/rc2t1mprsagADNI32Ch.nii'
                                                                './T1/rc1t1mprsagADNI32Ch.nii'
                                                                };
matlabbatch{2}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {'./DWI/DistortionCorrected'};
