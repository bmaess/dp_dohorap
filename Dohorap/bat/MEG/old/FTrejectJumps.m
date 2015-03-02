function [cfgOut, artifacts] = MEGrejectJumps(cfgIn)
    % Jump Artifact rejection
    cfgIn.artfctdef.zvalue.channel    = 'MEG';
    cfgIn.artfctdef.zvalue.cutoff     = 24;
    cfgIn.artfctdef.zvalue.trlpadding = 0;
    cfgIn.artfctdef.zvalue.artpadding = 0.2;
    cfgIn.artfctdef.zvalue.fltpadding = 0;
    cfgIn.artfctdef.zvalue.cumulative    = 'yes';
    cfgIn.artfctdef.zvalue.medianfilter  = 'yes';
    cfgIn.artfctdef.zvalue.medianfiltord = 9;
    cfgIn.artfctdef.zvalue.absdiff       = 'yes';
    [cfgArtefact, artifacts] = ft_artifact_zvalue(cfgIn);
    cfgArtefact.artfctdef.reject = 'complete';
    disp(['Subject ' num2str(subject) ', Block ' num2str(block) ': ft_rejectartifact']);
    [cfgOut, artifacts] = ft_rejectartifact(cfgArtefact);
end