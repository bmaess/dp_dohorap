
% addpath('/Users/goocy/Documents/Matlab/NIFTI_20130306/');
eval1 = load_untouch_nii('./AP/EVAL_wlsq_M_u0000-1.nii');
eval2 = load_untouch_nii('./AP/EVAL_wlsq_M_u0000-2.nii');
eval3 = load_untouch_nii('./AP/EVAL_wlsq_M_u0000-3.nii');
evecX1 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-x1.nii');
evecX2 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-x2.nii');
evecX3 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-x3.nii');
evecY1 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-y1.nii');
evecY2 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-y2.nii');
evecY3 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-y3.nii');
evecZ1 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-z1.nii');
evecZ2 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-z2.nii');
evecZ3 = load_untouch_nii('./AP/EVEC_wlsq_M_u0000-z3.nii');

T = zeros(size(eval1));
for x = 1:size(eval1.img,1)
    tic;
    for y = 1:size(eval1.img,2)
        for z = 1:size(eval1.img,3)
            T(x,y,z) = EVfunction(eval1.img(x,y,z),eval2.img(x,y,z),eval3.img(x,y,z),...
                evecX1.img(x,y,z),evecX2.img(x,y,z),evecX3.img(x,y,z),...
                evecY1.img(x,y,z),evecY2.img(x,y,z),evecY3.img(x,y,z),...
                evecZ1.img(x,y,z),evecZ2.img(x,y,z),evecZ3.img(x,y,z));
        end;
    end;
    toc
end;
