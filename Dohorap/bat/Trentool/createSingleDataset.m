function data = createSingleDataset(subjectPath, timewindow)
% Load the data
file = cell(1,2);
condText = {'obj','subj'};
timescale = -1:0.001:4;
fsample = 1000;
file{1} = load([subjectPath '/Obj_normal_unfiltered-epo.mat']);
file{2} = load([subjectPath '/Subj_normal_unfiltered-epo.mat']);

% Desired output format:
%       .trial     = cell array (1 x trials) containing
%                    data in the format (channels x samples)
%       .time      = cell (1 x trials) containing the time indices for
%                    each trial (1 x seconds)
%       .label     = cell (1 x channels), containing the labels
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
connectedAreas = connectRegions();
channels = unique(connectedAreas);
for cond = 1:2
   data = struct();
   data.time = {};
   data.trial = {};
   data.fsample = fsample;
   % Assemble labels
   data.label = channels;
   % Fill the trials section with loaded data
   for i = 1:higherCount
      data.time{1,i} = timescale;
      trialData = [];
      for n = 1:numel(channels)
         regionalData = [];
         channel = channels{n};
         % convert pSTG-rh to rh_pSTG
         areaParts = strsplit(channel,'-');
         convertedArea = [areaParts{2} '_' areaParts{1}];
         % retrieve data stream
         eval(['regionalData = file{cond}.' convertedArea '{i};']);
         % Assemble source and goal data streams
         trialData = [trialData; regionalData'];
      end
      data.trial{1,i} = trialData;
   end
   save([subjectPath '/' condText{cond} '-' timewindow '.mat'], 'data');
end
clear file


% Evidence for this structure from the code:
% cc = 1:size(datacell,1) % the number of channel combinations
% pp = pp = 1:size(datacell,2)  %%%% ML: TODO; MW note: number of channels in a combination (??)
% nrtrials(ii,pp) = size(datacell{ii,pp},1)
