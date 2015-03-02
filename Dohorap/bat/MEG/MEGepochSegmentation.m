function [cfg, epochs] = MEGepochSegmentation(cfg, goal)
    cfg.continuous = 'yes';
    cfg.lpfilter = 'yes';
    cfg.demean = 'no';
    if goal == 1 % for ERP data
        cfg.lpfreq = 12;
        cfg.filternote = 'l12h0.4';
    else % for frequency analysis
        cfg.filternote = 'l320';
        cfg.lpfreq = 320;
        cfg.lpfilttype = 'fir';
        cfg.lpfiltdir = 'onepass';
        % careful: this could introduce a (predictable) time offset
    end;
    epochs = ft_preprocessing(cfg);
end