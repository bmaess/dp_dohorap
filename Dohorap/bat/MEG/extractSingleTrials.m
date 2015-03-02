clear;
addpath('/scr/kuba1/Matlab/fieldtrip_120925/external/mne');
basePath = ('/scr/kuba2/Dohorap/Main/Data/MEG/motionCorrected/');
for subject = [2:19, 52:71];
    s = ['dh' num2str(subject,'%02i'),'a'];
    onsetSamples = [];
    stimulusCodes = [];
    trials = [];
    MEGblock = cell(1,2);
    dataLength = 0;
    blockTrial = 0;
    
    % Read and combine .mat epoch files
    raw_out = fiff_setup_read_raw([basePath s '/' s '1_mc.fif']);
    for b = 1:2
        block = num2str(b);
        matFilename = [basePath s '/' s block '_mc-decision-rejectedEpochs.mat'];
        load(matFilename);
        trialCount = numel(epochs.trial);
        MEGblock{b} = cell2mat(epochs.trial);
        for trial = 1:trialCount
            onsetSamples = [onsetSamples, dataLength];
            dataLength = dataLength + size(epochs.trial{trial},2);
            stimulusCodes = [stimulusCodes, epochs.trialinfo(trial,2)];
            trials = [trials, blockTrial + trial];
        end;
        blockTrial = trial;
    end;
    
    % Write .eve file
    onsetTimes = onsetSamples ./ epochs.fsample;
    z = zeros(size(onsetTimes));
    eveData = [onsetSamples', onsetTimes', z', stimulusCodes'];
    eveFilename = [basePath s '/mc-decision-rejectedEpochs.eve'];
    dlmwrite(eveFilename, eveData, 'delimiter', ' ', 'precision', 12);

    % Write .fif file
    fiffFilename = [basePath s '/mc-decision-rejectedEpochs.fif'];
    FIFF = fiff_define_constants;
    data = cell2mat(MEGblock);
    raw_out.first_samp = 1;
    raw_out.last_samp = dataLength;
    [outfid, cals] = fiff_start_writing_raw(fiffFilename, raw_out.info);
    raw_out.cals = cals;
    from        = raw_out.first_samp;
    to          = raw_out.last_samp;
    quantum_sec = 60; % process a minute at a time
    quantum     = ceil(quantum_sec*raw_out.info.sfreq);
    first_buffer = true;
    i = 1;
    for first = from:quantum:to
        last = first + quantum - 1;
        if last > to
            last = to;
        end
        if first_buffer
            if first > 0
                fiff_write_int(outfid,FIFF.FIFF_FIRST_SAMPLE,first);
            end
            first_buffer = false;
        end
        fiff_write_raw_buffer(outfid, data(:,first:last), cals);
        i = i + 1;
    end
    fiff_finish_writing_raw(outfid);
end;