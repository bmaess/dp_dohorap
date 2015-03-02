function [img] = mask(img6)
% tpm.img = img7;
% tpm.hdr.dime.dim(5) = 7;
% save_untouch_nii(tpm,'/SCR/hsonntag/spm12b/tpm/TPM_hso.nii');

img_1 = img6(:,:,:,1);
img_2 = img6(:,:,:,2);
img_3 = img6(:,:,:,3);
img_4 = img6(:,:,:,4);
img_5 = img6(:,:,:,5);
idx_1 = img_1==max(img6,[],4);
idx_2 = img_2==max(img6,[],4);
idx_3 = img_3==max(img6,[],4);
idx_4 = img_4==max(img6,[],4);
idx_5 = img_5==max(img6,[],4);
img = zeros(size(img_4),'uint8');
img(idx_1) = 1;
img(idx_2) = 2;
img(idx_3) = 3;
img(idx_4) = 4;
img(idx_5) = 5;

end