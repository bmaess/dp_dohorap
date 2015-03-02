clear; 
cfg_prep = [];
% for MacOS
% addpath('../../Documents/MATLAB/TRENTOOL2/');
% for Linux
addpath('../Matlab/TRENTOOL2/');

load('reconstructedDipoles-size20.mat'); % contains a variable called locatedDipoles:
% the base is a 2D cell array: {source x trials}
% each entry contains a struct:
% - reconstructedMoments: (radius x direction x timepoint)
% - radius: [minDiameter maxDiameter]

sources = size(locatedDipoles,1);
trials = size(locatedDipoles,2);
radii = size(locatedDipoles{1,1}.reconstructedMoments,1);
momentSize = size(squeeze(locatedDipoles{1,1}.reconstructedMoments(1,:,:)));
diameter = locatedDipoles{1,1}.radius;

data.fsample = 1000;
data.label = cell(1,2);
data.label{1} = 'main';
data.label{2} = 'induced';
data.time = cell(1,trials);
for trial = 1:trials
    data.time{trial} = 0.001:0.001:0.001*momentSize(2);
end;

% for MacOS: cfg_prep.Path2TSTOOL = '../../Downloads/OpenTSTOOL';
% for Linux: cfg_prep.Path2TSTOOL = '../Matlab/OpenTSTOOL';
cfg_prep.Path2TSTOOL = '../Matlab/OpenTSTOOL';
cfg_prep.optimizemethod='cao'; % select the CAO method to estimate embedding dimensions
cfg_prep.toi = [0 momentSize(2)/data.fsample]; % the time interval of interest in secs 
cfg_prep.predicttimemin_u = 10; % the prediction time im ms (e.g. the axonal delay; always choose bigger values when in doubt - also see the Vicente, 2010 paper)
cfg_prep.predicttimemax_u = 30;
cfg_prep.predicttimestepsize = 1;
cfg_prep.TEcalctype = 'VW';
% cfg.channel = data.label; % a cell array with the names of the channles you want to analyze. here all cahnnels in the dataset are analyzed
cfg_prep.sgncmb={'main', 'induced'};
cfg_prep.caodim = 1:5; % check dimensions between 1 and 8;
cfg_prep.caokth_neighbors = 4;
cfg_prep.caotau = 1.2;
cfg_prep.trialselect='no';
cfg_prep.feedback = 'yes';

cfg_result = [];
cfg_result.tail = 1;
cfg_result.optdimusage = 'indivdim';
cfg_result.surrogatetype = 'trialshuffling'; % the type of surrogates that are created for significance testing

% create one dataset (sources x trials) for each localization radius
for radius = 1:radii
    cfg_result.fileidout = strcat('./TE/Moments_', num2str(radius+(diameter(1)-1)), 'mm_'); % a prefix for the results filename
    data.trial = cell(1,trials);
    stream = zeros(sources,momentSize(1),momentSize(2));
    for trial = 1:trials
        for source = 1:2
            stream(source,:,:) = locatedDipoles{source, trial}.reconstructedMoments(radius,:,:);
        end;
        data.trial{1,trial} = squeeze(sqrt(stream(:,1,:).^2 + stream(:,2,:).^2 + stream(:,3,:).^2));
    end;
    result=InteractionDelayReconstruction_calculate(cfg_prep,cfg_result,data);
    save(['./TE/result_' num2str(radius+(diameter(1)-1)) 'mm.mat'], 'result');
    cfg_analysis.select_opt_u = 'max_TEdiff'; %'product_evidence'
    cfg_analysis.select_opt_u_pos = 'shortest';
    analysis = InteractionDelayReconstruction_analyze(cfg_analysis,result);
    save(['./TE/analysis_' num2str(radius+(diameter(1)-1)) 'mm.mat'], 'analysis');
end;

%% Plotting
radius = 3;
cfgPT.directory = '/Users/goocy/Dropbox/model/TE/';
cfgPT.pattern = ['Moments_' num2str(radius+(diameter(1)-1)) 'mm__RAG4_TGA_u_*_time0-1.8s_TEpermtest_output.mat'];
cfgPT.scaleytpe = 'lin';
InteractionDelayReconstruction_plotting(cfgPT);
