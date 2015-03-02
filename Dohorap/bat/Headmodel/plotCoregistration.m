function plotCoregistration(s, headmodelfile, dipolefile, megfile)
needed = [0,0,0];

% Load head model
if exist(headmodelfile,'file');
    [nodes, ~] = read_vista_mesh(headmodelfile);
    nodeIndices = 1:size(nodes,1);
    headIndices = randsample(nodeIndices, 12000);
    head = nodes(headIndices,:);
    needed(1) = 1;
    clear nodes;
else
    disp([headmodelfile ' not found, skipping plot']);
end;

% Load dipoles
if exist(dipolefile, 'file') && needed(1);
    dip = sb_read_dip(dipolefile);
    dipIndices = 1:size(dip,1);
    dipoleIndices = randsample(dipIndices, 2000);
    dipoles = double(dip(dipoleIndices,:));
    needed(2) = 1;
    clear dip;
else
    disp([dipolefile ' not found, skipping plot']);
end;

% Load electrode positions
if exist(megfile, 'file') && needed(2); 
    rawMEG = fiff_setup_read_raw(megfile);
    trans_1to4 = rawMEG.info.dev_head_t.trans;
    coil_trans = shiftdim(reshape(cat(1, rawMEG.info.chs(strncmp(rawMEG.info.ch_names, 'MEG', 3)).coil_trans), 4, 306, 4), 1);
    coilpos = squeeze(coil_trans(:, 4, 1:3));
    coilpos(:, 4) = 1;
    coilpos = coilpos*trans_1to4';
    coilpos = coilpos(:,1:3);
    needed(3) = 1;
    clear rawMEG trans_1to4 coil_trans;
else
    disp([megfile ' not found, skipping plot']);
end;

% Plot everything
if needed(3);
    f = figure();
    hold on;
    scatter3(head(:,1),head(:,2),head(:,3),'b.');
    scatter3(dipoles(:,1),dipoles(:,2),dipoles(:,3),'r.');
    scatter3(coilpos(:,1),coilpos(:,2),coilpos(:,3),'go');
    hold off;

    % Write plot to file
    print(f, [getenv('DOCDIR') '/Headmodel/coregistration-' s '-top.png'],'-dpng');
    view(90, 0);
    print(f, [getenv('DOCDIR') '/Headmodel/coregistration-' s '-side.png'],'-dpng');
    close(f);
end;