batdir = getenv('BATDIR');
addpath([batdir, '/Segmentation']);
addpath([batdir, '/Headmodel']);

grid = load('mesh.mat');
label = load('label.mat');
grid.vert = grid.vert * 0.001;
grid.vert(:, 4) = 1;
grid.vert = double(grid.vert) * alignMeshToHeadCoordinates(grid.subjectID)';
grid.vert = grid.vert(:,1:3);
write_vista_mesh('head.v', grid.vert, double(grid.elem + 1), double(label.label + 100));

