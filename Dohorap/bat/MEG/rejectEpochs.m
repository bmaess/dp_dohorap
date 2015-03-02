function epochs, cfg = rejectEpochs(paths, s, suffix, recreate, do);

for block = 1:2
    rejectedEpochsName = [paths.MEG s s num2str(block) suffix '-rejectedEpochs.mat'];
    rejectedListsName = [paths.MEG s s num2str(block) suffix '-rejectionLists.mat'];

    % Trial rejection
    if exist(rejectedEpochsName,'file') && recreate.rejection == 0
        disp(['Loading rejected epochs from subject ' s ' (block ' num2str(block) ')']);
        load(rejectedEpochsName); % loads epochs, cfg, jumpEpochs
    else
        disp(['Creating rejected epochs for subject ' s]);
        cfg = MEGDefineTrials(paths.MEG, paths.presentation, paths.data, suffix, subject, block);
        % Detection for jump artifacts
        [~, epochsWeaklyFiltered] = MEGepochSegmentation(cfg, 2);
        jumpEpochs = detectDeviations(epochsWeaklyFiltered, suffix, 1:306, 5, 3e-10, do.print);
        clear epochsWeaklyFiltered;
        % Check if there is an EOG/ECG-corrected version available
        EOGfile = calculateFilename(cfg.dataset, suffix.);
        if exist(EOGfile, 'file')
            cfg.dataset = EOGfile;
        end;

        [cfg, epochs] = MEGepochSegmentation(cfg, 1);
        if do.save
            save(rejectedEpochsName, 'jumpEpochs', 'cfg', 'epochs');
            save(rejectedListsName, 'jumpEpochs');
        end;
    end;

    % Define rejected trials
    jumpRejections = (any(jumpEpochs ~= 0)');
    speedRejections = rejectLowPerformers(cfg.trl, 90);

    % Glue the two blocks together
    if block == 1
        epochsOld = epochs;
        cfgOld = cfg;
        jumpRejectionsOld = jumpRejections;
        speedRejectionsOld = speedRejections;
    else
        epochs.time = {epochsOld.time{:} epochs.time{:}};
        epochs.trial = {epochsOld.trial{:} epochs.trial{:}};
        epochs.sampleinfo = [epochsOld.sampleinfo; epochs.sampleinfo];
        epochs.trialinfo = [epochsOld.trialinfo; epochs.trialinfo];
        clear epochsOld;
        cfg.event = [cfgOld.event; cfg.event];
        cfg.trl = [cfgOld.trl; cfg.trl];
        jumpRejections = [jumpRejectionsOld; jumpRejections];
        speedRejections = [speedRejectionsOld; speedRejections];
    end
end
cfg.jumpRejections = jumpRejections;
cfg.speedRejections = speedRejections;
end