seg = load_untouch_nii('./Segmented/segmented_drls_1mm_cfg3.nii');
i = seg.img;
save_untouch_nii(i == 1, './Segmented/MSK_rc1t1mprsagADNI32Ch.nii');
save_untouch_nii(i == 2, './Segmented/MSK_rc2t1mprsagADNI32Ch.nii');