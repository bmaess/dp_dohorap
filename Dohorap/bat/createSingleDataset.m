function data = createSingleDataset(subjectPath)
% Load the data
file = cell(1,2);
condText = {'obj','subj'};
timescale = -1:0.001:4;
fsample = 1000;
file{1} = load([subjectPath '/Obj_normal-epo.mat']);
file{2} = load([subjectPath '/Subj_normal-epo.mat']);

% Desired output format:
%       .trial     = cell array (channel tests x trials) containing
%                    data in the format (data streams x samples)
%       .time      = cell (1 x trials) containing the time indices for
%                    each trial (1 x seconds)
%       .label     = cell (1xnr of channels), containing the labels
%                    (strings) of channels included in the data

% Both datasets need to have an equal number of trials.
% Fill up the missing trials with random samples from itself:
ROIs = fieldnames(file{1});
trialCount = zeros(1,2);
for cond = 1:2;
    trialCount(cond) = numel(file{cond}.lh_aSTG);
end
[lowerCount, fewerTrials] = min(trialCount);
[higherCount, moreTrials] = max(trialCount);
randomLowerTrials = randsample(1:lowerCount, higherCount, 'true');
for i = lowerCount+1:higherCount
    randomLowerTrial = randomLowerTrials(i);
    for roiID = 1:numel(ROIs)
        roi = ROIs{roiID};
        eval(['file{fewerTrials}.' roi '{i,1} = file{fewerTrials}.' roi '{randomLowerTrial,1};']);
    end
end

% Create Trentool data structure
for cond = 1:2
    data = struct();
    data.time = cell(1,1);
    data.trial = cell(1,1);
    data.label = {'pSTG', 'BA45'};
    data.fsample = fsample;
    for i = 1:higherCount
        p = file{cond}.lh_pSTS{i}';
        b = file{cond}.lh_BA44{i}';
        data.time{1,i} = timescale;
        data.trial{1,i} = [p; b];
        data.trial{2,i} = [b; p];
    end
    save([subjectPath '/' condText{cond} '.mat'], 'data');
end
clear file

% Evidence for this structure from the code:
% cc = 1:size(datacell,1) % the number of channel combinations
% pp = pp = 1:size(datacell,2)  %%%% ML: TODO; MW note: number of channels in a combination (??)
% nrtrials(ii,pp) = size(datacell{ii,pp},1)