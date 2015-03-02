clear;

gradfactor = 1e13;
magfactor = 1e15;
gradlimit = [-100 100];
maglimit  = [-450 450];
trigger = 1;
nsamps = 2001;
conditions = {'forward','reverse'};

basePath = '/scr/kuba1/Dohorap/Main/Data/';
% basePath = '/Users/goocy/Documents/';
MEGpath = [basePath 'MEG/motionCorrected'];
graphPath = [basePath 'doc/'];
addpath('/scr/kuba1/Matlab/fieldtrip_120925/external/mne/');
averageMags = cell(1,2);
averageGrads = cell(1,2);
magSNR = cell(1,2);
gradSNR = cell(1,2);

if trigger == 1
    suffix = 'onset';
elseif trigger == 2
    suffix = 'feedback';
elseif trigger == 3
    suffix = 'decision';
end;

for subject = [2:19 52:71];
    subjectString = ['/dh' num2str(subject, '%02i') 'a'];
    for block = 1:2
        rejectedEpochsName = [MEGpath subjectString subjectString num2str(block) '_mc-rejectedEpochs.mat'];
        load (rejectedEpochsName); % loads epochs, cfg, EOGepochs, jumpEpochs
        rejectionList = (any(jumpEpochs ~= 0))';
        % Glue the two blocks together
        if block == 1
            epochsOld = epochs;
            cfgOld = cfg;
            rejectionListOld = rejectionList;
        else
            epochs.time = {epochsOld.time{:} epochs.time{:}};
            epochs.trial = {epochsOld.trial{:} epochs.trial{:}};
            epochs.sampleinfo = [epochsOld.sampleinfo; epochs.sampleinfo];
            epochs.trialinfo = [epochsOld.trialinfo; epochs.trialinfo];
            clear epochsOld;
            cfg.event = [cfgOld.event; cfg.event];
            cfg.trl = [cfgOld.trl; cfg.trl];
            rejectionList = [rejectionListOld; rejectionList];
        end;
    end;
    
    raw_header = fiff_setup_read_raw([ basePath '/MEG' subjectString subjectString '1.fif' ]);
    
    mags = find(sum(epochs.hdr.grad.tra,2)==1);
    grads = find(sum(epochs.hdr.grad.tra,2)<1);
    
    for condition = 1:2
        magStrength = zeros(size(mags));
        magVariation = zeros(size(mags));
        gradStrength = zeros(size(grads));
        gradVariation = zeros(size(grads));

        % andere trigger codes unterstützen!
        if condition == 1
            stimulusCodes = [211 212];
        elseif condition == 2
            stimulusCodes = [221 222];
        end;
        for trial = 1:size(epochs.trialinfo,1)
            codeSelection(trial) = any(epochs.trialinfo(trial, 2) == stimulusCodes);
        end;
        cfg = [];
        cfg.vartrllength = 2;
        cfg.trials = codeSelection;
        avgData = ft_timelockanalysis(cfg,epochs);
        avgMag = avgData.avg(mags,:);
        avgGrad = avgData.avg(grads,:);
        if condition == 1
            timescale = avgData.time;
        end;
        if size(timescale,2) > size(avgData.time,2) % take the shorter timescale
            timescale = avgData.time;
        end;

        magStrength = magStrength + max(abs(avgMag(:,500:2000)'))';
        magVariation = magVariation + var(avgMag(:,500:2000),0,2);
        gradStrength = gradStrength + max(abs(avgGrad(:,500:2000)'))';
        gradVariation = gradVariation + var(avgGrad(:,500:2000),0,2);
        averageMags{1,condition} = avgMag;
        averageGrads{1,condition} = avgGrad;
        
        [~,sMags] = sort(magStrength./magVariation);
        magSNR{1,condition} = magStrength./magVariation;
        [~,sGrads] = sort(gradStrength./gradVariation);
        gradSNR{1,condition} = gradStrength./gradVariation;
        clear stimulusCodes trial codeSelection magStrength gradStrength magVariation gradVariation
        
        % Write average fif file
        mne_evoked.info               = raw_header.info;
        mne_evoked.info.projs         = mne_evoked.info.comps;
        mne_evoked.evoked.aspect_kind =  100;
        mne_evoked.evoked.is_smsh     =    0;
        mne_evoked.evoked.nave        = numel(epochs.time); % waer besser mit einer anderen Lösung
        mne_evoked.evoked.first       = epochs.time{1}(1,1)*1000; % in ms
        mne_evoked.evoked.last        = (mne_evoked.evoked.first/1000+(nsamps-1)/mne_evoked.info.sfreq)*1000; % am ende in ms 

        mne_evoked.evoked.times       = linspace(mne_evoked.evoked.first,mne_evoked.evoked.last,nsamps);
        mne_evoked.evoked.epochs      = zeros(mne_evoked.info.nchan,nsamps);
        mne_evoked.evoked.comment     = conditions{condition}; 
        mne_evoked.evoked.epochs(mags,:) = averageMags{condition}(:,1:nsamps);
        mne_evoked.evoked.epochs(grads,:) = averageGrads{condition}(:,1:nsamps);

        fiff_write_evoked([MEGpath subjectString subjectString '-l12h0.4-average-' suffix '_' conditions{condition} '.fif'],mne_evoked);
        clear mne_evoked
    end;
    
    % Calculate Covariance matrix
    kov_example=mne_read_noise_cov('/scr/eber2/predaud/pa07a/pa07a3_mch05l30ss_avr-cov.fif');
    cfg = [];
    cfg.vartrllength = 2;
    cfg.trials = 'all';
    cfg.removemean = 'no';
    cfg.covariancewindow = 'prestim';
    cfg.covariance = 'yes';
    avgData = ft_timelockanalysis(cfg,epochs);
    kov_example.data = avgData.cov;
    covFile = [MEGpath subjectString subjectString '-l12h0.4-' suffix '-cov.fif'];
    mne_write_cov_file(covFile, kov_example);
    
%% Display
    mainPlot = figure('Color',[0 0 0]);
    set(mainPlot,'paperunits','centimeters');
    set(mainPlot,'papersize',[32, 10.8]);
    set(mainPlot,'paperposition',[0,0,32,10.8]);
    set(mainPlot,'InvertHardCopy', 'off');
    grey = [0.8, 0.8, 0.8];
    for sensortype = 1:2
        for condition = 1:2
            samplescale = 1:size(timescale,2);
            h = subplot(2,2,(sensortype-1)*2+condition, 'Parent', mainPlot);
            grid (h, 'on');
            set(h, 'XColor', grey); set(h, 'YColor', grey);
            xlim ([-0.2 0.8]); xlabel ('time after decision point in ms', 'Color', grey);
            if condition == 1
                conditionText = 'forward (subject-object)';
                color = [0 0.3 0];
            else
                conditionText = 'reverse (object-subject)';
                color = [0 0 0.6];
            end;
            if sensortype == 1
                plot_butterfly(timescale, averageMags{1,condition}(sMags,samplescale) * magfactor, color);
                sensorText = 'Magnetometers';
                ylabel ('field amplitude (fT)', 'Color', grey); ylim (maglimit);
            else
                plot_butterfly(timescale, averageGrads{1,condition}(sGrads,samplescale) * gradfactor, color);
                sensorText = 'Gradiometers';
                ylabel ('field gradient (fT/m)', 'Color', grey);  ylim (gradlimit);
            end;
            title ([sensorText ' in the ' conditionText ' condition'], 'Color', grey);
        end;
    end;
    print(mainPlot, [graphPath 'fieldtripButterfly' subjectString '-conditionContrast-' suffix '.png'],'-dpng')
end;
%end;