function MEGhighpass(paths, suffix, infile, outfile)
    cfg = [];
    firFile = 'hp_004_4367pts_1000Hz.fir';
    firData = importdata(firFile);
    firStart = find(sum(cellfun(@(x) strcmp('[fir]',x), firData.textdata),2)); % find the index of the [fir] tag
    coeffLength = str2num(firData.textdata{firStart+1,1}); % read out the length of filter coefficients
    coeffs = cell(1,coeffLength); % prepare an empty cell array with the length of the imported coefficients
    [coeffs{:}] = firData.textdata{firStart+2:end, 1}; % copy only the coefficients to the empty array (discard the header)
    cfg.filtvec = cellfun(@str2double, coeffs); % convert the cell array of strings to an array of double values
    cfg.ch_idxs = 1:306;
    cfg.filter = 'asy';
    cfg.rawfile = infile;
    cfg.outfile = outfile;
    fiff_filter_raw_data(cfg)
end