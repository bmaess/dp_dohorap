function prepareSingleDataset(data, outFiles)
    fsample = 1000;
    cfgTEP.sgncmb = {'pSTG','BA45';'BA45','pSTG'};
    cfgTEP.Path2TSTOOL = '/scr/kuba2/Matlab/OpenTSTOOL';
    cfgTEP.toi = [-.8, 1.0];
    cfgTEP.predicttime_u = 12;
    cfgTEP.predicttimemin_u    = 2;      % minimum u to be scanned
    cfgTEP.predicttimemax_u    = 24;	  % maximum u to be scanned
    cfgTEP.predicttimestepsize = 2; 	  % time steps between u's to be scanned
    cfgTEP.optimizemethod = 'ragwitz';
    cfgTEP.ragdim = 1:6;
    cfgTEP.ragtaurange = [0.1 0.4]; % vector (1x2) of min and max embedding delays (in
    %                                     multiples of the autocorrelation decay time)
    cfgTEP.ragtausteps = 6;
    cfgTEP.flagNei = 'Mass'; % 'Range' or 'Mass' type of neighbor search
    cfgTEP.sizeNei = 4; % Radius or mass for the neighbor search according to flagNeighborhood

    % repPred represents the number of points for which the prediction is
    % performed. We try to get it as high as possible.
    sampleLength = floor(diff(cfgTEP.toi) * fsample);
    dim = max(cfgTEP.ragdim);
    maxACT = 275;
    tau = ceil(max(cfgTEP.ragtaurange) * maxACT);
    u = cfgTEP.predicttimemax_u;
    embeddingSamples = (dim-1)*tau + u + maxACT
    cfgTEP.repPred = sampleLength - embeddingSamples - 1;

    % ACT: autocorrelation time; describes how long the autocorrelation peak takes to sink to 0
    cfgTEP.TheilerT = 'ACT';
    cfgTEP.trialselect = 'no';
    cfgTEP.actthrvalue = maxACT; % in samples; minimum ACT to consider a trial valid
    if strcmp(cfgTEP.trialselect, 'range')
        cfgTEP.trial_from = 1;
        cfgTEP.trial_to = 20;
    end
    cfgTEP.maxlag = 300; % set as high as possible on the first run (time span in cfg.toi in samples)
                          % and drastically reduce to 2*max(ACT) for any similar data
    for cond=1:2
        dataPrepared = TEprepare(cfgTEP, data{cond});
        save(outFiles{cond}, 'dataPrepared');
    end
end
