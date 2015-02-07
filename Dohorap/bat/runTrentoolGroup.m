clear
firstRun = 1;
if firstRun
    addpath('/Users/goocy/Documents/MATLAB/TRENTOOL3.3.1/');
    addpath('/Users/goocy/Documents/MATLAB/fieldtrip_120925');
    ft_defaults
end

%% Create a variable with all the datasets
dataPath = '/Users/goocy/Documents/141222 Dissertation/Dohorap/Localized';
cd(dataPath);
conds = {'obj','subj'};
% Find all subjectIDs
subjects = [];
dirEntries = dir(dataPath);
for i = 1:numel(dirEntries)
    entryName = dirEntries(i).name;
    entryLength = numel(entryName);
    if entryLength == 5
        if strcmp(entryName(1:2),'dh')
            subjects = [subjects; entryName];
        end
    end
end
clear dirEntries entryName entryLength
subjectCount = size(subjects,1);

% Build a list of all prepared dataset files (and create them if necessary)
dataFiles = cell(1,subjectCount*numel(conds));
n = 1;
for i = 1:subjectCount
    subject = subjects(i,:);
    subjectPath = [dataPath '/' subject];
    for c = 1:numel(conds)
        cond = conds{c};
        relativeOutFile = [subject '/' cond '.mat'];
        absoluteOutFile = [subjectPath '/' cond '.mat'];
        dataFiles{n} = relativeOutFile;
        n = n+1;
        if ~exist(absoluteOutFile, 'file')
            createSingleDataset(subjectPath);
        end
    end
end
clear n i cond outFiles subject subjectPath

%% Prepare the group analysis
cfgTEGP = struct();
fsample = 1000;
cfgTEGP.sgncmb = {'pSTG','BA45';'BA45','pSTG'};
cfgTEGP.Path2TSTOOL = '/Users/goocy/Documents/MATLAB/OpenTSTOOL';
cfgTEGP.toi = [0, 0.8];
cfgTEGP.optimizemethod = 'ragwitz';
cfgTEGP.ragdim = 1:6;
cfgTEGP.ragtaurange = [0.01 0.4]; % vector (1x2) of min and max embedding delays (in
%                                     multiples of the autocorrelation decay time)
cfgTEGP.ragtausteps = 8;

cfgTEGP.predicttimemin_u    = 4;      % minimum u to be scanned
cfgTEGP.predicttimemax_u    = 36;	  % maximum u to be scanned
cfgTEGP.predicttimestepsize = 4; 	  % time steps between u's to be scanned

cfgTEGP.flagNei = 'Mass'; % 'Range' or 'Mass' type of neighbor search
cfgTEGP.sizeNei = 4; % Radius or mass for the neighbor search according to flagNeighborhood

% repPred represents the number of points for which the prediction is
% performed. We try to get it as high as possible.
sampleLength = floor(diff(cfgTEGP.toi) * fsample);
dim = max(cfgTEGP.ragdim);
maxACT = 155;
tau = ceil(max(cfgTEGP.ragtaurange) * maxACT);
u = cfgTEGP.predicttimemax_u;
embeddingSamples = (dim-1)*tau + u + maxACT
cfgTEGP.repPred = sampleLength - embeddingSamples - 1;

% ACT: autocorrelation time; describes how long the autocorrelation peak takes to sink to 0
cfgTEGP.TheilerT = 'ACT';
cfgTEGP.trialselect = 'no';
cfgTEGP.actthrvalue = maxACT; % in samples; minimum ACT to consider a trial valid
if strcmp(cfgTEGP.trialselect, 'range')
    cfgTEGP.trial_from = 1;
    cfgTEGP.trial_to = 20;
end
cfgTEGP.maxlag = 1800; % set as high as possible on the first run (time span in cfg.toi in samples)
                      % and drastically reduce to 2*max(ACT) for any similar data
cfgTEGP.outputpath = dataPath;
%%
TEgroup_prepare(cfgTEGP, dataFiles);

%% Calculate the interaction delays

cfgTESS = struct();
cfgTESS.optdimusage = 'maxdim'; % 'maxdim' to use maximum of optimal dimensions over
%                      all channels for all channels, or 'indivdim' to use
%                      the individual optimal dimension for each channel.
%                      In case of using ragwitz criterion also the optimal
%                      embedding delay tau per channelcombi is used.
cfgTESS.alpha = 0.05;
cfgTESS.surrogatetype = 'trialshuffling';
cfgTESS.extracond = 'Faes_Method'; % Should remove volume conductor effects
cfgTESS.shifttest = 'no';
cfgTESS.permstatstype = 'indepsamplesT'; % 'mean' to use the distribution of the mean differences and 'depsamplesT' or 'indepsamplesT' for distribution of the t-values.

for n = 1:numel(dataFiles)
    infile = dataFiles{n};
    outfile = [infile(1:end-4) '-results.mat'];
    f = load(infile);
    data = f.data;
    cfgTESS.fileidout = infile(1:end-4);
    TGAresults = InteractionDelayReconstruction_calculate(cfgTEGP, cfgTESS, data);
    save(outfile, 'TGAresults');
end


%% Calculate the results
cfgTEGS = struct();
condCount = numel(conds);
subjectIDs = zeros(1,subjectCount * condCount);
conditions = zeros(1,subjectCount * condCount);
resultFiles = cell(1, subjectCount * condCount);
i = 1;
for s = 1:subjectCount
    subject = subjects(s,:);
    subjectPath = [dataPath '/' subject];
    for cond = 1:condCount
        subjectIDs(i) = s;
        conditions(i) = cond;
        resultFiles{i} = [subjectPath '/' conds{cond} '-results.mat'];
        i = i+1;
    end
end
cfgTEGS.design = [subjectIDs; conditions];
cfgTEGS.uvar = 1; % Row with the subjects
cfgTEGS.ivar = 2; % Row with the conditions
cfgTEGS.permstatstype = 'indepsamplesT'; % ?mean?: use the distribution of the mean differences
% ?depsamplesT? (for dependent samples) or ?indepsamplesT? (for independent samples):
% use the distribution of the t-values
cfgTEGS.numpermutation = 190100;
cfgTEGS.tail = 2; % one- or two-tailed test of significance
cfgTEGS.alpha = 0.05;
cfgTEGS.correctm = 'FDR'; % Correct for multiple comparisons with 'FDR' or 'BONF'
cfgTEGS.fileidout = 'groupstats'; % Output file stem    
TEgroup_stats(cfgTEGS, resultFiles);