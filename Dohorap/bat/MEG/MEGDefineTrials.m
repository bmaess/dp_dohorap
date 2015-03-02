function cfgOut = MEGDefineTrials(MEGpath, PresentationPath, dataPath, suffix, subject, block)
    cfg.trialfun = 'findTriggers';
    cfg.triggertype = suffix;
    cfg.showcallinfo = 'no';
    cfg.eventtype = [211 212 221 222];
    cfg.PresentationPath = PresentationPath;
    cfg.subject = subject;
    cfg.block = block;
    cfg.dataPath = dataPath;
    prefix = ['/dh' num2str(subject,'%02i') 'a/dh' num2str(subject,'%02i') 'a'];
    cfg.dataset = [MEGpath prefix num2str(block) '_mc.fif'];
    disp(['Subject ' num2str(subject) ', Block ' num2str(block) ': ft_definetrial']);
    cfgOut = ft_definetrial(cfg);
    invalidTrials = any(cfgOut.trl(:,8:9)'<0);
    cfgOut.trl(invalidTrials,:) = [];
end
