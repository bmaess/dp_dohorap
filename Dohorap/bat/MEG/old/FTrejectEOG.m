function [cfgOut, artifacts] = MEGrejectEOG(cfgIn)
    cfgIn.continuous = 'yes';
    cfgIn.artfctdef.zvalue.channel     = 'EOG';
    cfgIn.artfctdef.zvalue.cutoff      = 8.5;
    cfgIn.artfctdef.zvalue.trlpadding  = 0;
    cfgIn.artfctdef.zvalue.artpadding  = 0.2;
    cfgIn.artfctdef.zvalue.fltpadding  = 0;
    cfgIn.artfctdef.zvalue.bpfilter   = 'yes';
    cfgIn.artfctdef.zvalue.bpfilttype = 'but';
    cfgIn.artfctdef.zvalue.bpfreq     = [1 15];
    cfgIn.artfctdef.zvalue.bpfiltord  = 4;
    cfgIn.artfctdef.zvalue.hilbert    = 'yes';
    [cfgOut, artifacts] = ft_artifact_zvalue(cfgIn);
end