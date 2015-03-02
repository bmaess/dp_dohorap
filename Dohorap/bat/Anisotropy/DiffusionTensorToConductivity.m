function ConductivityTensor = DiffusionTensorToConductivity(DiffusionTensor)
% Extracting eigenvalues
Eigenvalues = zeros(size(DiffusionTensor,1),3);
Eigenvalues(:,1) = DiffusionTensor(:,1);
Eigenvalues(:,2) = DiffusionTensor(:,5);
Eigenvalues(:,3) = DiffusionTensor(:,9);
mask = load_untouch_nii('./Segmented/segmented_drls_1mm_cfg3.nii');
gMask = mask.img == 1;
wMask = mask.img == 2;

% Extracting GM and WM eigenvalues
GMeigenvalues = Eigenvalues(gMask(:),:);
WMeigenvalues = Eigenvalues(wMask(:),:);

% Calculating S (following Rullmann et al, NeuroImage 2009)
GMsigma = 0.33;
WMsigma = 0.142;
GMdiffusivity = nthroot(mean(prod(GMeigenvalues,2)),3);
WMdiffusivity = nthroot(mean(prod(WMeigenvalues,2)),3);
s = (WMdiffusivity * WMsigma + GMdiffusivity * GMsigma) / (GMdiffusivity^2 + WMdiffusivity^2);

% Calculating conductivity tensor from diffusion tensor
ConductivityTensor = DiffusionTensor * s;
end
