% Load diffusion tensor and convert to Vista-compatible conductivity tensor
t = load('./DWI/TensorData/DiffusionTensor.mat');
eval1 = load_untouch_nii('./DWI/TensorData/EVAL_robust_ru0000-1.nii');
diffusionTensor = t.T;
Tsize = t.Tsize;
c = DiffusionTensorToConductivity(diffusionTensor);
clear diffusionTensor;
% Each conductivity tensor is a matrix in the order [XX,YX,ZX; XY,YY,ZY; XZ,YZ,ZZ]
% Vista wants each tensor in the order [XX,XY,XZ,YY,YZ,ZZ]
%meshTensor = [c(:,1,1), c(:,1,2), c(:,1,3), c(:,2,1), c(:,2,2), c(:,2,3), c(:,3,1), c(:,3,2), c(:,3,3)];
meshTensor = squeeze(reshape(c, [], 9,1));
meshTensor = reshape(meshTensor,Tsize(1), Tsize(2), Tsize(3), 9);
for i = 1:9
    eval1.img = squeeze(meshTensor(:,:,:,i));
    niiname = ['./DWI/TensorData/c-' num2str(i) '.nii'];
    save_untouch_nii(eval1, niiname);
end;
clear c;
save('./DWI/TensorData/ConductivityTensor.mat','meshTensor');
