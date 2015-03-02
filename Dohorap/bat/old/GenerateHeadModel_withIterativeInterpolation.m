clear
subjects = [11 52 54 55 56 58 59 60 62 63 64 66 67 68];
tissues = [6 4 2 5 1 3];
addpath('/media/truecrypt1/SCR/sw/spm12b/');
addpath('/media/truecrypt1/SCR/Matlab/nifti');
for subject = subjects
    % Load and combine probability maps into a variable called data
    disp(['Processing subject ' num2str(subject) '...']);
    MEGpath = ['/media/truecrypt1/SCR/Dohorap/Main/Data/MRI/dh' num2str(subject) 'a/'];
    
    % Pre-scale probability maps, so that certain tissue layers get prescedence
    % grey white csf skull soft air
    weight = [1.3 1 1 1 1 1];
    for tissue = 1:size(weight,2)
        filename = [MEGpath 'c' num2str(tissues(tissue)) 't2spcsagp2iso.nii'];
        c = spm_vol(filename);
        if tissue == 1
            data = zeros([c.dim,6]);
        end;
        cdata = spm_read_vols(c);
        data(:,:,:,tissue) = cdata*weight(tissue);
    end;
    clear c cdata limits tissue filename weight;

    %% Interpolate the probability maps from 6 to 16 layers
    % bg bg2skull1 skull2bg1 skull skull2white1 white2skull1 white white2scalp1 scalp1white2 scalp scalp2grey1 grey2scalp1 grey grey2csf1 csf2grey1 csf
    weight = [1 1.1 1.1        1       1.2          1.3        1        1.5          1.5       1      1.5          1.5       1.2     1.5       1.5     1.2];
    dataSize = size(data);
    fineTissues = 3*(dataSize(4));
    fineData = zeros(dataSize(1),dataSize(2),dataSize(3),fineTissues-2);
    
    % generate two grids: one with the original resolution, and one with the interpolated number of tissues
    [xi,yi,ti] = ndgrid(1:dataSize(1),1:dataSize(2),1:dataSize(4)/(fineTissues):dataSize(4));
    [x,y,t] = ndgrid(1:dataSize(1),1:dataSize(2),1:dataSize(4));
    
    % for memory purposes, interpolate in only 3 dimensions simultaneously, and loop over the 4th
    for z = 1:dataSize(3)
        fineData(:,:,z,:) = interpn(x,y,t,squeeze(data(:,:,z,:)),xi,yi,ti);
    end;
    
    % Scale the probability of the interpolated tissues (because otherwise, the traditional tissues would always "win" in the next command)
    for t = 1:dataSize(4)
        fineData(:,:,:,t) = fineData(:,:,:,t)*weight(t);
    end;
    
    % For each voxel, select the most probable tissue and store its index (1-6) into a new segmentation map
    [~,segmentedImage] = max(fineData,[],4);
    
    data = fineData;
    clear fineData x y t xi yi ti z
    
    %% clean up the segmented image
    % Initialize some variables
    binary = zeros(size(segmentedImage));
    refinedImage = segmentedImage;
    combinedCompartmentCount = [];
    i = 0;
    improvement = [];
    gradientSoftened = 0;
    stopOptimizing = 0;
    waitCycle = 0;
    
    % Set up factors for decreasing the tissue-specific probability
    % smaller conductivities should get higher numbers
    % grey white csf skull soft air
    g = [1.8 2 1 4 1.4 5];
    gradient = interp1(1:size(g,2),g,1:dataSize(4)/(fineTissues):dataSize(4));
    % Prevent interpolation between skull and CSF
    gradient(
    
    
    % Start removing small voxel clusters until stop conditions are met
    while stopOptimizing == 0
        i = i+1;
        compartmentCount = [];
        for tissue = 1:size(data,4)
            
            % Count the size of each compartment in a certain segmentation map
            cdata = squeeze(data(:,:,:,tissue));
            binary(:,:,:) = refinedImage==tissue;
            CC = bwconncomp(binary);
            compartmentSizes = cellfun(@numel,CC.PixelIdxList);
            tissueCompartmentCount = size(compartmentSizes,2);
            if i == 1
                biggestCompartment = max(compartmentSizes);
            end;
            
            % Select the compartments smaller than 1% the size of the biggest one
            changeMatrix = ones(size(cdata));
            totalCompartmentSize = 0;
            for compartment = 1:tissueCompartmentCount
                compartmentSize = compartmentSizes(compartment);
                if compartmentSize < biggestCompartment * 0.01
                    
                    % Scale down the probability of the voxels associated with the selected (small) compartment
                    % These voxels will later "lose" to another tissue layer with higher probability
                    % For speed reasons, these scaling indices are stored in a separate matrix
                    changeMatrix(CC.PixelIdxList{compartment}) = 1/gradient(tissue);
                    totalCompartmentSize = totalCompartmentSize + compartmentSize;
                end;
            end;
            
            % The scaling indices are used to modify the 4D 'data' matrix, lowering the amount of (time-consuming) entry replacements
            data(:,:,:,tissue) = cdata(:,:,:) .* changeMatrix;
            compartmentCount = [compartmentCount totalCompartmentSize];
        end;
        combinedCompartmentCount = [combinedCompartmentCount; compartmentCount];
        disp(['Iteration ' num2str(i), ': improvement of ', num2str(sum(combinedCompartmentCount(1,:))./sum(combinedCompartmentCount(i,:))-1)]);
        % Detect stop conditions during iteration
        if i > 2
            if waitCycle == 0
                if gradientSoftened < 4
                    
                    % Detect compartment size oscillations, which indicates that the scaling factors are too strong
                    if any(combinedCompartmentCount(i-1,:)<combinedCompartmentCount(i,:))
                        
                        % Soften the gradient by weakening the scaling factors
                        gradient = sqrt(gradient);
                        gradientSoftened = gradientSoftened + 1;
                        disp('Oscillation detected; softening gradient and waiting 4 iterations');
                        waitCycle = 4;
                    end;
                    
                    % Detect the asymptotic condition
                    if combinedCompartmentCount(i-1,:) == combinedCompartmentCount(i,:)
                        stopOptimizing = 1;
                    end;
                else
                    stopOptimizing = 1;
                end;
            else
                waitCycle = waitCycle -1;
            end;
        end;
        [~,refinedImage] = max(data,[],4);
    end;
    clear data;
    volume = zeros(2,6);
    for tissue = 1:6
        volume(1,tissue) = sum(sum(sum(segmentedImage==tissue))) * (0.488/100)^2;
        volume(2,tissue) = sum(sum(sum(refinedImage==tissue))) * (0.488/100)^2;
    end;
    save([MEGpath 'VolumeInCm3AfterCleaning.mat'], 'volume');

    % save the refined segmented image
    nii.img = uint8(refinedImage*10);
    nii.hdr = load_nii_hdr([MEGpath 'c1t2spcsagp2iso.nii']);
    save_nii(nii,[MEGpath 'segmented.nii']);
    clear nii

    % convert nii to vista mesh
    % !../convert2nii dh58a
    % do it manually until libstdc++ issue is fixed
end;