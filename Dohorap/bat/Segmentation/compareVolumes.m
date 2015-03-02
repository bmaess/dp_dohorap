t = importdata('segmentationVolumes.txt');
datasize = size(t.data,1);
subject = cell(1,datasize);
approach = cell(1,datasize);
tissue = zeros(1,datasize);
volume = zeros(1,datasize);
for i = 1:datasize
    subjects{i} = t.textdata{i+1,1};
    approaches{i} = t.textdata{i+1,2};
    tissues(i) = t.data(i,1);
    volumes(i) = t.data(i,2);
end
approachCount = size(unique(approaches),2);
subjectCount = size(unique(subjects),2);
tissueCount = size(unique(tissues),2);
vols = zeros(subjectCount, tissueCount, approachCount);
i = 1;
for tissue = 1:tissueCount
    for approach = 1:approachCount
        for subject = 1:subjectCount
            vols(subject, tissue, approach) = volumes(i);
            i = i+1;
        end
    end
end

sdPooled = sqrt(sum(squeeze(var(vols)),2)/2)';
DRLSvols = mean(vols(:,:,1),1);
MLvols = mean(vols(:,:,2),1);
zScore = (DRLSvols - MLvols) ./ (sdPooled .* sqrt(2./subjectCount))
volDiff = 100*((DRLSvols./MLvols)-1)