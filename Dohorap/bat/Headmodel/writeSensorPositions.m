expdir = getenv('EXPDIR');
headdir = getenv('HEADDIR');
for subject = [1:12 14:16 52:60 62:69]
    s = ['dh' num2str(subject,'%02i') 'a'];
    % Transformation from 1 to 4 (device -> head):
    rawMEG = fiff_setup_read_raw([expdir s '/' s '1.fif']);
    trans_1to4 = rawMEG.info.dev_head_t.trans;

    coil_trans = shiftdim(reshape(cat(1, rawMEG.info.chs(strncmp(rawMEG.info.ch_names, 'MEG', 3)).coil_trans), 4, 306, 4), 1);
    coilpos = squeeze(coil_trans(:, 4, 1:3));
    coilpos(:, 4) = 1;
    coilrot = squeeze(coil_trans(:, 1:3, 1:3));
    coilrot(:, 4) = 1;
    chanori = squeeze(coilrot(:, 1, :));
    chanori(:, 4) = 1;
    coildir = squeeze(coilrot(:, 3, :));
    coildir(:, 4) = 1;
    chanori = chanori*trans_1to4';
    coildir = coildir*trans_1to4';
    coilpos = coilpos*trans_1to4';
    write_grd_file_neuromag([headdir, '/' s '/neuromag.grd'], coilpos(:, 1:3), coildir(:, 1:3), chanori(:, 1:3));
end;