clear
%addpath('/Users/goocy/Documents/MATLAB/spm12b/external/mne');

% Generated by printMNEchannelLocations.py:
Left_frontal_mag = [5, 26, 29, 32, 35, 50, 53, 56, 59, 62, 65, 71, 89];
Right_frontal_mag = [86, 92, 95, 98, 101, 104, 107, 110, 128, 131, 134, 137, 152];
Left_parietal_mag = [38, 41, 44, 47, 68, 74, 83, 182, 200, 203, 206, 209, 224];
Right_parietal_mag = [77, 80, 113, 116, 119, 122, 125, 227, 248, 251, 254, 257, 281];
Left_temporal_mag = [2, 8, 11, 14, 17, 20, 23, 164, 167, 170, 173, 176, 179];
Right_temporal_mag = [140, 143, 146, 149, 155, 158, 161, 272, 275, 296, 299, 302, 305];
Left_occipital_mag = [185, 188, 191, 194, 197, 212, 215, 218, 221, 233, 236, 245];
Right_occipital_mag = [230, 239, 242, 260, 263, 266, 269, 278, 284, 287, 290, 293];
Left_frontal_grad = [3, 4, 24, 25, 27, 28, 30, 31, 33, 34, 48, 49, 51, 52, 54, 55, 57, 58, 60, 61, 63, 64, 69, 70, 87, 88];
Right_frontal_grad = [84, 85, 90, 91, 93, 94, 96, 97, 99, 100, 102, 103, 105, 106, 108, 109, 126, 127, 129, 130, 132, 133, 135, 136, 150, 151];
Left_parietal_grad = [36, 37, 39, 40, 42, 43, 45, 46, 66, 67, 72, 73, 81, 82, 180, 181, 198, 199, 201, 202, 204, 205, 207, 208, 222, 223];
Right_parietal_grad = [75, 76, 78, 79, 111, 112, 114, 115, 117, 118, 120, 121, 123, 124, 225, 226, 246, 247, 249, 250, 252, 253, 255, 256, 279, 280];
Left_temporal_grad = [0, 1, 6, 7, 9, 10, 12, 13, 15, 16, 18, 19, 21, 22, 162, 163, 165, 166, 168, 169, 171, 172, 174, 175, 177, 178];
Right_temporal_grad = [138, 139, 141, 142, 144, 145, 147, 148, 153, 154, 156, 157, 159, 160, 270, 271, 273, 274, 294, 295, 297, 298, 300, 301, 303, 304];
Left_occipital_grad = [183, 184, 186, 187, 189, 190, 192, 193, 195, 196, 210, 211, 213, 214, 216, 217, 219, 220, 231, 232, 234, 235, 243, 244];
Right_occipital_grad = [228, 229, 237, 238, 240, 241, 258, 259, 261, 262, 264, 265, 267, 268, 276, 277, 282, 283, 285, 286, 288, 289, 291, 292];

% Prepare sensor layout
sensorPositions = zeros(306,3);
aveDir = '/Users/goocy/Documents/141222 Dissertation/Dohorap/averages';
epochFile = [aveDir '/dh12a/Obj_average-ave.fif'];
epoch = fiff_read_evoked(epochFile);
mags = false(1,306);
mags(3:3:306) = true;
grads = false(1,306);
gradSelection = sort([1:3:304, 2:3:305]);
grads(gradSelection) = true;
sensorchannels = {mags, grads};
sensorcolors = {[0.8, 0.4, 0], [0.8, 0, 0.4]};

for i = 1:306
    sensorPositions(i,:) = epoch.info.chs(i).coil_trans(1:3,4);
end
[ttheta,tphi,~]=cart2sph(sensorPositions(:,1),sensorPositions(:,2),sensorPositions(:,3));
[sensorsX,sensorsY]=pol2cart(ttheta,pi/2-tphi);

sensortypes = {'mag','grad'};
directions = {'Left','Right'};
locations = {'frontal','parietal','temporal','occipital'};
for l = 1:4
    f = figure();
    set(gcf,'paperunits','centimeters')
    set(gcf,'papersize',[20,20])
    set(gcf,'paperposition',[0,0,20,20])
    location = locations{l};
    layoutPosition = [0 0 1 1]; % left bottom width height
    for d = 1:2
        direction = directions{d};
        sensID = 1;
        sensorSelection = sensorchannels{sensID};            

        layoutSub = axes('Parent',f, 'Position', layoutPosition);

        xPos = sensorsX(sensorSelection);
        yPos = sensorsY(sensorSelection);
        t = scatter(xPos, yPos, 360, [0,0,0], 'LineWidth', 1.5);
        hold all;

        eval(['c = ' direction '_' location '_' sensortypes{sensID} ';']);
        channelSelection = false(1,306);
        channelSelection(c+1) = true;
        xPos = sensorsX(sensorSelection & channelSelection);
        yPos = sensorsY(sensorSelection & channelSelection);
        sensorcolor = sensorcolors{sensID};
        scatter(xPos, yPos, 120, [0,0,0], 'filled', 'LineWidth', 1.5);
        if d == 1
            scatter(xPos, yPos, 360, [0,0,0], 'MarkerEdgeColor', [0,0,0], 'LineWidth', 1.5);
        else
            scatter(xPos, yPos, 360, [0,0,0], 'MarkerEdgeColor', sensorcolor, 'LineWidth', 1.5);
        end

        set(layoutSub, 'DataAspectRatio', [1 1 1]);
        set(layoutSub, 'Color', 'None');
        set(layoutSub, 'Visible', 'off');
    end
    hold off;
    
    % Save the result
    filename = ['3_3_' location '_sensors'];
    print(f, [filename '.png'], '-dpng', '-r300');
    close(f);

end
