function write_dip(matfile, dipfile, corFile)

dip = load(matfile);

% rescale sources to head coordinates
dip.vert = dip.vert*0.001; % scale to m
dip.vert(:, 4) = 1;
dip.vert = double(dip.vert) * alignMeshToHeadCoordinates(corFile)';
dip.vert = dip.vert(:,1:3);

sb_write_dip(dip.vert, dipfile)
end