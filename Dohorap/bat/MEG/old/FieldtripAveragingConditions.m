function averageData = FieldtripAveragingConditions(epochs, suffix, rejectionList, doPrint, folderComment)
    conditionCodes = {[211 212],[221 222]};
    soundCodes = epochs.trialinfo(:,2);
    averageData = cell(1,2);
    
    for rejected = 1:2
        for condition = 1:2
            cfg = [];
            cfg.covariancewindow = 'prestim';
            cfg.covariance = 'yes';
            cfg.vartrllength = 2;
            cfg.triggertype = suffix;
            cfg.trials = ismember(soundCodes, conditionCodes{condition});
            switch rejected
                case 1; thisSuffix = [suffix '-noRejection'];
                    cfg.trials = ones(size(rejectionList));
                case 2; thisSuffix = [suffix '-rejected'];
                    cfg.trials = cfg.trials & ~rejectionList;
            end;
            averageData{1,condition} = ft_timelockanalysis(cfg,epochs);
        end;
        if doPrint
                magChannels(1,1) = find(strcmp(epochs.label, 'MEG0211'));
                magChannels(1,2) = find(strcmp(epochs.label, 'MEG1511'));
                magChannels(1,3) = find(strcmp(epochs.label, 'MEG0241'));
                magChannels(1,4) = find(strcmp(epochs.label, 'MEG0131'));
                gradChannels(1,1) = find(strcmp(epochs.label, 'MEG0242'));
                gradChannels(1,2) = find(strcmp(epochs.label, 'MEG0243'));
                plotERP(averageData, sum(cfg.trials==1), magChannels, gradChannels, thisSuffix, folderComment);
        end;
    end;
end
