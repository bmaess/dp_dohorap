addpath('/Users/goocy/Documents/MATLAB/TRENTOOL3/');
addpath('/Users/goocy/Documents/MATLAB/fieldtrip_120925');
ft_defaults
clear

%% Load the data
useRealData = 1;
file = cell(1,2);
timescale = -1:0.001:4;
fsample = 1000;
if useRealData
    file{1} = load('../Localized/dh10a/Obj_normal-epo.mat');
    file{2} = load('../Localized/dh10a/Subj_normal-epo.mat');

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
    data = cell(1,2);
    for cond = 1:2
        data{cond} = struct();
        data{cond}.time = cell(1,1);
        data{cond}.trial = cell(1,1);
        data{cond}.label = {'pSTG', 'BA45'};
        data{cond}.fsample = fsample;
        for i = 1:higherCount
            p = file{cond}.lh_pSTS{i}';
            b = file{cond}.lh_BA44{i}';
            data{cond}.time{1,i} = timescale;
            data{cond}.trial{1,i} = [p; b];
            data{cond}.trial{2,i} = [b; p];
        end
    end
    clear file

% cc = 1:size(datacell,1) % the number of channel combinations
% pp = pp = 1:size(datacell,2)  %%%% ML: TODO; MW note: number of channels in a combination (??)
% nrtrials(ii,pp) = size(datacell{ii,pp},1)
else
    offset = 1800;
    shiftmean = {20, 40};
    shiftsd = {8, 12};
    data = cell(1,2);
    % Create one slow sample and some high-frequency data
    ERP = cell(1,2);
    for stream = 1:2;
        e = randn(1,5001);
        t = conv(ones(1,120)./120,e); ERP{stream} = t(26:5026);
    end
    HF = randn(1,5001);
    t = conv(ones(1,24)./7,HF); HF = t(9:5009);
    for cond = 1:2
        data{cond} = struct();
        data{cond}.time = cell(1,1);
        data{cond}.trial = cell(1,1);
        data{cond}.label = {'pSTG', 'BA45'};
        data{cond}.fsample = fsample;
        for i = 1:160
            data{cond}.time{1,i} = timescale;
            % Create two random samples in three speeds
            noise = cell(1,2);
            for stream = 1:2
                x1 = randn(1, 5001);
                t = conv(ones(1,4)./4,x1); x1 = t(3:5003);
                x2 = randn(1,5001);
                t = conv(ones(1,24)./24,x2); x2 = t(9:5009);
                x3 = randn(1,5001);
                t = conv(ones(1,120)./120,x3); x3 = t(26:5026);
                noise{stream} = (0.1*x1 + 0.5*x2 + x3)./3;
            end
            % Create a data-rich deviation
            randomOffset = offset + shiftmean{cond} + round(shiftsd{cond} * randn);
            dev = gausswin(200)' + 0.5*HF(1:200);
            shiftedDeviation = [zeros(1,randomOffset), dev, zeros(1,5001-randomOffset-200)];
            deviation = [zeros(1,offset), dev, zeros(1,5001-offset-200)];

            % Assemble the components
            firstStream = ERP{1} + 1.0*deviation + 0.5*noise{1};
            secondStream = ERP{2} + 1.0*shiftedDeviation + 0.5*noise{2};
            data{cond}.trial{1,i} = [firstStream; secondStream];
            data{cond}.trial{2,i} = [secondStream; firstStream];
        end
    end
end

%% Prepare the data
cfgTEP.sgncmb = {'pSTG','BA45';'BA45','pSTG'};
cfgTEP.Path2TSTOOL = '/Users/goocy/Documents/MATLAB/OpenTSTOOL';
cfgTEP.toi = [0.35, 0.80];
cfgTEP.predicttime_u = 10;
cfgTEP.predicttimemin_u    = 2;      % minimum u to be scanned
cfgTEP.predicttimemax_u    = 20;	  % maximum u to be scanned
cfgTEP.predicttimestepsize = 2; 	  % time steps between u's to be scanned
cfgTEP.optimizemethod = 'ragwitz';
if strcmp(cfgTEP.optimizemethod, 'ragwitz')
    cfgTEP.ragdim = 1:5;
    cfgTEP.ragtaurange = [0.2 0.4]; % vector (1x2) of min and max embedding delays (in
%                                     multiples of the autocorrelation decay time)
    cfgTEP.ragtausteps = 6;
    cfgTEP.flagNei = 'Mass'; % 'Range' or 'Mass' type of neighbor search
    cfgTEP.sizeNei = 5; % Radius or mass for the neighbor search according to flagNeighborhood
    cfgTEP.repPred = floor(diff(cfgTEP.toi) * fsample / 4); % repPred represents the
                     % number of points for which the prediction is performed.
                     % It has to be smaller than length(timeSeries)-(dim-1)*tau-u)

else % CAO is recommended for fMRI Data, but deprecated for MEEG data
    cfgTEP.caodim = 1:5;
    cfgTEP.caokth_neighbors = 4;
    cfgTEP.caotau = 1.5;
    cfgTEP.kth_neighbors = 4;
end
% ACT: autocorrelation time; describes how long the autocorrelation peak takes to sink to 0
cfgTEP.TheilerT = 'ACT';
cfgTEP.trialselect = 'no';
cfgTEP.actthrvalue = 200; % in samples; minimum ACT to consider a trial valid
if strcmp(cfgTEP.trialselect, 'range')
    cfgTEP.trial_from = 1;
    cfgTEP.trial_to = 20;
end
cfgTEP.maxlag = 300; % set as high as possible on the first run (time span in cfg.toi in samples)
                      % and drastically reduce to 2*max(ACT) for any similar data

dataPrepared = cell(1,2);
for cond=1:2; dataPrepared{cond} = TEprepare(cfgTEP, data{cond}); end

%% Prepare the single dataset analysis
cfgTECSS = struct();
cfgTECSS.shifttest = 'yes';
cfgTECSS.shifttesttype = 'TE>TEshift';
cfgTECSS.shifttype = 'onesample'; % shifts by cfg.predicttime_u, otherwise use 'onesample'
cfgTECSS.permstatstype = 'indepsamplesT'; % 'mean? to use the distribution of the mean differences and ?depsamplesT? or ?indepsamplesT? for distribution of the t-values.
cfgTECSS.numpermutation = 190100;
cfgTECSS.tail = 2; % one- or two-tailed test for significance
cfgTECSS.alpha = 0.05;
cfgTECSS.correctm = 'FDR'; % FDR: False discovery rate, BONF: Bonferroni correction
cfgTECSS.fileidout = 'firsttest';
cfgTECSS.extracond = 'None'; % 'None' or 'Faes_Method'

TEconditionstatssingle(cfgTECSS, dataPrepared{1}, dataPrepared{2});