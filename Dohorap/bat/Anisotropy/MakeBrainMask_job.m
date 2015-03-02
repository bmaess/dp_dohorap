%-----------------------------------------------------------------------
% Job saved on 19-Jun-2013 15:13:37 by cfg_util (rev $Rev: 3034 $)
% spm SPM - SPM12b (5373)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.dti.prepro_choice.make_brainMSK.PSEG = {
                                                                 './Segmented/rc1t1mprsagADNI32Ch.nii,1'
                                                                 './Segmented/rc2t1mprsagADNI32Ch.nii,1'
                                                                 };
matlabbatch{1}.spm.tools.dti.prepro_choice.make_brainMSK.perc1 = 0.8;
matlabbatch{1}.spm.tools.dti.prepro_choice.make_brainMSK.PDTImasked = {
                                                                      './DWI/TensorData/EVAL_robust_ru0000-1.nii,1'
                                                                      './DWI/TensorData/EVAL_robust_ru0000-2.nii,1'
                                                                      './DWI/TensorData/EVAL_robust_ru0000-3.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-x1.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-x2.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-x3.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-y1.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-y2.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-y3.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-z1.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-z2.nii,1'
                                                                      './DWI/TensorData/EVEC_robust_ru0000-z3.nii,1'
                                                                      };
%%
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {'./DWI'};
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = 'Masked';
%%
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.files = {
                                                                './DWI/Segmented/MSK_rc1t1mprsagADNI32Ch.nii'
                                                                './DWI/Segmented/MSK_rc2t1mprsagADNI32Ch.nii'
                                                                };
matlabbatch{3}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = {'./DWI/Masked'};
