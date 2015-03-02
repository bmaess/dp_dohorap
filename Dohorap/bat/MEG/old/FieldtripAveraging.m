function averageData = FieldtripAveraging(epochs, suffix, rejectionList, doPrint, folderComment)
    conditionCodes = {[211 212],[221 222]};
    soundCodes = epochs.trialinfo(:,2);
    averageData = cell(1,2);
    
    for rejected = 1:2
        cfg = [];
        cfg.covariancewindow = 'prestim';
        cfg.covariance = 'yes';
        cfg.vartrllength = 2;
        cfg.triggertype = suffix;
        switch rejected
            case 1; thisSuffix = [suffix '-noRejection']; cfg.trials = 'all';
            case 2; thisSuffix = [suffix '-rejected']; cfg.trials = rejectionList;
        end;
        averageData = ft_timelockanalysis(cfg,epochs);
        
        if doPrint
            plotButterfly(epochs, averageData, thisSuffix, folderComment);
        end;
    end;
end
