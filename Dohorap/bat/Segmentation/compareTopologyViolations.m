clear
suffices = {'', '-ML'};
MRIpath = '/scr/kuba1/Dohorap/Main/Data/MRI/';
addpath('/scr/kuba1/automatedsegmentation/ML');
subjectIDs = [52:60 62:69];
useMesh = 0;
tissueIDs = 0:5;
overallComparison = zeros(length(subjectIDs), 2);
times = [];
layer = 4;
if useMesh; prefix = 'mesh_'; else prefix = 'segmented_drls_1mm_cfg3'; end
for subjectID = 1:length(subjectIDs)
    subject = ['dh' num2str(subjectIDs(subjectID)) 'a'];
    disp(subject);
    subjectfilestem = [MRIpath subject '/Segmented/' prefix];
    for suffix = 1:2
        tic;
        tissueComparison = zeros(1,length(tissueIDs));
        outfile = [subjectfilestem suffices{suffix} '-leaks_mesh.mat'];
        if useMesh; headmesh = load([subjectfilestem suffices{suffix} '.mat']);
        else seg = load_untouch_nii([subjectfilestem suffices{suffix} '.nii']); end
        if suffix==1
            if useMesh; %headmesh = mesh_leakage_correct(headmesh, layer, layer);
            else disp(''); end
        end
        if useMesh; t = size(mesh_leakage_count(headmesh, layer),1);
        else t = size(img_leakdetect(seg, end;
        save(outfile, 'tissueComparison');
        overallComparison(subjectID, suffix) = t;
        times = [times, toc];
    end
end

errorsSkull = overallComparison(:,:);

sampleSize = size(errorsSkull,1);
sdPooled = sqrt(sum(var(errorsSkull))/2);
DRLSerrorsSkull = mean(errorsSkull(:,1),1);
MLerrorsSkull = mean(errorsSkull(:,2),1);
zScoreSkull = (MLerrorsSkull - DRLSerrorsSkull) / (sdPooled * sqrt(2/sampleSize))
differenceSkull = 100*((mean(MLerrorsSkull)/mean(DRLSerrorsSkull))-1)
% ML creates [differenceSkull]% more wrong voxels in the skull than DRLS, with a z-score of [zScoreSkull].
averageErrorsSkull = mean(errorsSkull,1)