function sens = sb_write_meg(cfg,filename,sensortype)
% cfg.target.chanpos = cfg.target.pnt;
% head = ft_read_headshape(filename,'format',sensortype);
% grad = ft_read_sens(filename);
% grad.fid.label = head.fid.label;
% grad.fid.chanpos = head.fid.pnt;
% clear head;
% sens = ft_sensorrealign(cfg,grad);

% %checken, ob das so alles passt hier!
% coilpos = zeros(3*size(sens.chanpos,1),3);
% coilpos(1:3:end,:) = sens.coilpos(5:5:end,:);
% coilpos(2:3:end,:) = sens.coilpos(5:5:end,:);
% coilpos(3:3:end,:) = sens.coilpos(5:5:end,:);
% coildir = zeros(3*size(sens.chanpos,1),3);
% coildir(1:3:end,:) = sens.coilori(1:5:end,:);
% coildir(2:3:end,:) = sens.coilori(2:5:end,:);
% coildir(3:3:end,:) = sens.coilori(3:5:end,:);
% %
% write_grd_file_neuromag(filename,coilpos,coildir,sens.chanori);

raw_in = fiff_setup_read_raw(filename);
coil_trans = shiftdim(reshape(cat(1, raw_in.info.chs(strncmp(raw_in.info.ch_names, 'MEG', 3)).coil_trans), 4, 306, 4), 1);
coilpos = squeeze(coil_trans(:, 4, 1:3));
coilrot = squeeze(coil_trans(:, 1:3, 1:3));
chanori = squeeze(coilrot(:, 1, :));
coildir = squeeze(coilrot(:, 3, :));
write_grd_file_neuromag(filename, coilpos, coildir, chanori);
end