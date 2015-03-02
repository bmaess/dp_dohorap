
% addpath('/Users/goocy/Documents/Matlab/NIFTI_20130306/');
eval1 = load_untouch_nii('./DWI/TensorData/EVAL_robust_ru0000-1.nii');
eval2 = load_untouch_nii('./DWI/TensorData/EVAL_robust_ru0000-2.nii');
eval3 = load_untouch_nii('./DWI/TensorData/EVAL_robust_ru0000-3.nii');
evecX1 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-x1.nii');
evecX2 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-x2.nii');
evecX3 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-x3.nii');
evecY1 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-y1.nii');
evecY2 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-y2.nii');
evecY3 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-y3.nii');
evecZ1 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-z1.nii');
evecZ2 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-z2.nii');
evecZ3 = load_untouch_nii('./DWI/TensorData/EVEC_robust_ru0000-z3.nii');
mask = load_untouch_nii('./Segmented/segmented_drls_1mm_cfg3.nii');

ev1 = eval1.hdr.dime.scl_inter + eval1.hdr.dime.scl_slope * double(reshape(eval1.img,1,[]));
ev2 = eval2.hdr.dime.scl_inter + eval2.hdr.dime.scl_slope * double(reshape(eval2.img,1,[]));
ev3 = eval3.hdr.dime.scl_inter + eval3.hdr.dime.scl_slope * double(reshape(eval3.img,1,[]));
X1 = evecX1.hdr.dime.scl_inter + evecX1.hdr.dime.scl_slope * double(reshape(evecX1.img,1,[]));
X2 = evecX2.hdr.dime.scl_inter + evecX2.hdr.dime.scl_slope * double(reshape(evecX2.img,1,[]));
X3 = evecX3.hdr.dime.scl_inter + evecX3.hdr.dime.scl_slope * double(reshape(evecX3.img,1,[]));
Y1 = evecY1.hdr.dime.scl_inter + evecY1.hdr.dime.scl_slope * double(reshape(evecY1.img,1,[]));
Y2 = evecY2.hdr.dime.scl_inter + evecY2.hdr.dime.scl_slope * double(reshape(evecY2.img,1,[]));
Y3 = evecY3.hdr.dime.scl_inter + evecY3.hdr.dime.scl_slope * double(reshape(evecY3.img,1,[]));
Z1 = evecZ1.hdr.dime.scl_inter + evecZ1.hdr.dime.scl_slope * double(reshape(evecZ1.img,1,[]));
Z2 = evecZ2.hdr.dime.scl_inter + evecZ2.hdr.dime.scl_slope * double(reshape(evecZ2.img,1,[]));
Z3 = evecZ3.hdr.dime.scl_inter + evecZ3.hdr.dime.scl_slope * double(reshape(evecZ3.img,1,[]));
m = mask.img == 2;
Tsize = size(eval1.img);
clear eval1 eval2 eval3 evecX1 evecX2 evecX3 evecY1 evecY2 evecY3 evecZ1 evecZ2 evecZ3 mask;

length = prod(Tsize);
eigenvectors = zeros(3,3,length);
eigenvectors(1,:,:) = [X1; X2; X3];
eigenvectors(2,:,:) = [Y1; Y2; Y3];
eigenvectors(3,:,:) = [Z1; Z2; Z3];
eigenvalues = [ev1; ev2; ev3];
clear ev1 ev2 ev3 X1 X2 X3 Y1 Y2 Y3 Z1 Z2 Z3;

T = EVfunction(m,eigenvalues, eigenvectors);
clear m eigenvalues eigenvectors;
save ('./DWI/TensorData/DiffusionTensor.mat','T','Tsize');
