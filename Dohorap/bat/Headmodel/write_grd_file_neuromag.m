function [ output ] = write_grd_file_neuromag( filename, coilpos, coildir, coilxdir )
%WRITE_GRD_FILE
% coilpos = #channels x 3 array, containing positions of channel centers
% corresponds to coilpos in fieldtrip
% coildir = #channels x 3 array, containing normal direction of channels
% corresponds to coilori in fieldtrip
% coilxdir = #channels x 3 array, containing x-direction of channels
% corresponds to chanori in fieldtrip?

fid=fopen(filename, 'w');

if (fid == -1)
fprintf('could not open file %s\n', filename);
else
NumberPositions = size(coilpos,1);
fprintf(fid, 'UnitArea sqmm \n');
fprintf(fid, 'NumberPositions= %d \n', NumberPositions);
fprintf(fid, 'UnitPositions= mm \n');            
fprintf(fid, 'Positions \n');   
for i=1:NumberPositions
    fprintf(fid, '%f\t%f\t%f \n', coilpos(i,1), coilpos(i,2), coilpos(i,3));
end
fprintf(fid, 'MeasType Tesla \n');
fprintf(fid, 'NumberCoils= 5 \n');
fprintf(fid, 'PositionCoils \n');
fprintf(fid, '0 0 0 0 0 \n');
fprintf(fid, 'AreaCoils \n');
fprintf(fid, '1 1 1 1 1 \n')
% fprintf(fid, '268 268 268 268 441 \n');
fprintf(fid, 'Windings \n');
fprintf(fid, '1 1 1 1 1 \n');
fprintf(fid, 'NumberIntPoints= 32 \n');
fprintf(fid, 'IntPoints \n');
fprintf(fid, '5.8900 6.7100    \n');
fprintf(fid, '5.8900 -6.7100   \n');
fprintf(fid, '10.8000 6.7100   \n');
fprintf(fid, '10.8000 -6.7100  \n');
fprintf(fid, '-5.8900 6.7100   \n');
fprintf(fid, '-5.8900 -6.7100  \n');
fprintf(fid, '-10.8000 6.7100  \n');
fprintf(fid, '-10.8000 -6.7100 \n');
fprintf(fid, '-6.7100 5.8900   \n');
fprintf(fid, '6.7100 5.8900    \n');
fprintf(fid, '-6.7100 10.8000  \n');
fprintf(fid, '6.7100 10.8000   \n');
fprintf(fid, '-6.7100 -5.8900  \n');
fprintf(fid, '6.7100 -5.8900   \n');
fprintf(fid, '-6.7100 -10.8000 \n');
fprintf(fid, '6.7100 -10.8000  \n');
fprintf(fid, '9.6800 9.6800    \n');
fprintf(fid, '-9.6800 9.6800   \n');
fprintf(fid, '9.6800 -9.6800   \n');
fprintf(fid, '-9.6800 -9.6800  \n');
fprintf(fid, '9.6800 3.2300    \n');
fprintf(fid, '-9.6800 3.2300   \n');
fprintf(fid, '9.6800 -3.2300   \n');
fprintf(fid, '-9.6800 -3.2300  \n');
fprintf(fid, '3.2300 9.6800    \n');
fprintf(fid, '-3.2300 9.6800   \n');
fprintf(fid, '3.2300 -9.6800   \n');
fprintf(fid, '-3.2300 -9.6800  \n');
fprintf(fid, '3.2300 3.2300    \n');
fprintf(fid, '-3.2300 3.2300   \n');
fprintf(fid, '3.2300 -3.2300   \n');
fprintf(fid, '-3.2300 -3.2300  \n');
fprintf(fid, 'Weights \n');
fprintf(fid, '0.01479 0.01479 0.01479 0.01479 -0.01479 -0.01479 -0.01479 -0.01479 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \n');
fprintf(fid, '0 0 0 0 -0.01479 -0.01479 -0.01479 -0.01479 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \n');
fprintf(fid, '0 0 0 0 0 0 0 0 0.01479 0.01479 0.01479 0.01479 -0.01479 -0.01479 -0.01479 -0.01479 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \n');
fprintf(fid, '0 0 0 0 0 0 0 0 0 0 0 0 -0.01479 -0.01479 -0.01479 -0.01479 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 \n');
fprintf(fid, '0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 0.0625 \n');
fprintf(fid, 'NoLabels \n');
fprintf(fid, 'NumberDirections= %d \n', NumberPositions);
fprintf(fid, 'Directions \n');
for i=1:NumberPositions
    fprintf(fid, '%f \t%f \t%f \n', coildir(i,1), coildir(i,2), coildir(i,3));
end
fprintf(fid, 'xDirections \n');
for i=1:NumberPositions
    fprintf(fid, '%f \t%f \t%f \n', coilxdir(i,1), coilxdir(i,2), coilxdir(i,3));
end
fprintf(fid, 'NumberChannels= %d \n', NumberPositions);
fprintf(fid, 'NumberChannelParts= 2 \n');
fprintf(fid, '#0 is blank \n');
fprintf(fid, 'ChannelCoilMatching \n');
for i=1:NumberPositions
    fprintf(fid,'%d \t%d\n', mod(2*(i - 1), 6) + 1, mod(2*(i) , 6));
end
fprintf(fid, 'ChannelDirectionMatching \n');
for i=1:NumberPositions
    fprintf(fid,'%d \t%d \n', i, i);
end
fprintf(fid, 'NumberPolygonPoints= 20 \n');
fprintf(fid, 'PolygonPoints \n');
fprintf(fid, '-13.5 \t13.4 \t0.3 \n');
fprintf(fid, '-13.5 \t-13.4 \t0.3 \n');
fprintf(fid, '-3.5 \t13.4 \t0.3 \n');
fprintf(fid, '-3.5 \t-13.4 \t0.3 \n');
fprintf(fid, '3.5 \t13.4 \t0.3 \n');
fprintf(fid, '3.5 \t-13.4 \t0.3 \n');
fprintf(fid, '13.5 \t13.4 \t0.3 \n');
fprintf(fid, '13.5 \t-13.4 \t0.3 \n');
fprintf(fid, '-13.5 \t13.4 \t0.3 \n');
fprintf(fid, '-13.5 \t-13.4 \t0.3 \n');
fprintf(fid, '-3.5 \t13.4 \t0.3 \n');
fprintf(fid, '-3.5 \t-13.4 \t0.3 \n');
fprintf(fid, '3.5 \t13.4 \t0.3 \n');
fprintf(fid, '3.5 \t-13.4 \t0.3 \n');
fprintf(fid, '13.5 \t13.4 \t0.3 \n');
fprintf(fid, '13.5 \t-13.4 \t0.3 \n');
fprintf(fid, '-10.5 \t10.5 \t0.3 \n');
fprintf(fid, '-10.5 \t-10.5 \t0.3 \n');
fprintf(fid, '10.5 \t10.5 \t0.3 \n');
fprintf(fid, '10.5 \t-10.5 \t0.3 \n');
fprintf(fid, 'TypePolygons= 2 \n'); 
fprintf(fid, 'NumberPolygonDefinition= 20 \n');
fprintf(fid, 'Polygons \n');
fprintf(fid, '0 2 \n');
fprintf(fid, '2 3 \n');
fprintf(fid, '3 1 \n');
fprintf(fid, '1 0 \n');
fprintf(fid, '0 1 \n');
fprintf(fid, '1 3 \n');
fprintf(fid, '3 2 \n');
fprintf(fid, '2 0 \n');
fprintf(fid, '0 2 \n');
fprintf(fid, '2 3 \n');
fprintf(fid, '3 1 \n');
fprintf(fid, '1 0 \n');
fprintf(fid, '0 1 \n');
fprintf(fid, '1 3 \n');
fprintf(fid, '3 2 \n');
fprintf(fid, '2 0 \n');
fprintf(fid, '0 1 \n');
fprintf(fid, '1 3 \n');
fprintf(fid, '3 2 \n');
fprintf(fid, '2 0 \n');
fprintf(fid, 'NumberDifferentPolygons= 5 \n');
fprintf(fid, 'DifferentPolygons \n');
fprintf(fid, '4 \n');
fprintf(fid, '4 \n');
fprintf(fid, '4 \n');
fprintf(fid, '4 \n');
fprintf(fid, '4 \n');
fprintf(fid, 'NumberPolygonUnits= %d \n', int32(NumberPositions/3));
end
output = fclose(fid);  
end                                                                                                                                                                                                                                                                                                                                                                                        
