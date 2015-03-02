clear
basePath = '/SCR/Dohorap/Main/Data/';
MEGpath = [basePath 'MEG/motionCorrected/'];
trigger = 3;
conditions = {'forward', 'reverse'};

for subject = [52:71]
    
    kov_example=mne_read_noise_cov('/scr/eber2/predaud/pa07a/pa07a3_mch05l30ss_avr-cov.fif');
    if trigger == 1
        suffix = 'onset';
    elseif trigger == 2
        suffix = 'feedback';
    elseif trigger == 3
        suffix = 'decision';
    end;
    s = ['dh' num2str(subject,'%02i') 'a'];
    
    filename = [MEGpath s '/' s '-l12h0.4-' suffix '.mat'];
    load (filename);
    
    cfg = [];
    cfg.covariancewindow = 'prestim';
    cfg.removemean = 'no';
    cfg.vartrllength = 2;
    cfg.covariance = 'yes';
    cfg.trials = 'all';
    avgData = ft_timelockanalysis(cfg,epochs);
    kov_example.data = avgData.cov;

    covFile = [MEGpath s '/' s '-l12h0.4-' suffix '-cov.fif'];
    mne_write_cov_file(covFile, kov_example);
    clear avgData cfg epochs
end;