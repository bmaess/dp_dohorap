clear
%addpath('/Users/goocy/Documents/MATLAB/spm12b/external/mne');
aveDir = '/Users/goocy/Documents/141222 Dissertation/Dohorap/averages';
dirEntries = dir(aveDir);
subjects = [];
groups = cell(1,2);
for d = 1:size(dirEntries,1)
    n = dirEntries(d).name;
    if length(n) > 1
        if strcmp(n(1:2), 'dh')
            subject = dirEntries(d).name;
            subjects = [subjects; subject];
            subjectID = str2num(subject(3:4));
            groups{(subjectID>50)+1} = subjects;
        end
    end
end

%% Load evoked data

allMags = 2:3:305;
allGrads = sort([0:3:303, 1:3:304]);
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
% Generated by printMNEchannelLocations.py

conditions = {'Obj', 'Subj'};
directions = {'Left', 'Right'};
locations = {'frontal', 'parietal', 'temporal'};
sensortypes = {'mag','grad'};

averageData = cell(2,2);
stdevData = cell(2,2);
for sensorID = 1:2
    sensortype = sensortypes{sensorID};
    for g = 1:numel(groups)
        group = groups{g};
        n = numel(group);
        subjectData = zeros(numel(group), numel(conditions), numel(directions), numel(locations), 5001);
        for s = 1:size(group,1)
            subject = group(s,:);
            for c = 1:numel(conditions)
                condition = conditions{c};
                epochFile = [aveDir '/' subject '/' condition '_average-ave.fif'];
                epoch = fiff_read_evoked(epochFile);
                for d = 1:numel(directions)
                    direction = directions{d};
                    for l = 1:numel(locations)
                        location = locations{l};
                        eval(['channelSelection = ' direction '_' location '_' sensortype '+1;']);
                        % Averaging over selected channels
                        if strcmp(sensortype, 'mag')
                            data = mean(epoch.evoked.epochs(channelSelection,:))';
                        else
                            data = sqrt(mean(epoch.evoked.epochs(channelSelection,:).^2,1))';
                        end
                        subjectData(s,c,d,l,:) = squeeze(subjectData(s,c,d,l,:)) + data;
                    end
                end
            end
        end
        % Build a grand average and grand standard deviation
        averageData{sensorID,g} = squeeze(mean(subjectData,1));
        varianceEstimator = zeros(numel(conditions), numel(directions), numel(locations), 5001);
        for s = 1:size(group,1)
            varianceEstimator = varianceEstimator + (squeeze(subjectData(s,:,:,:,:)) - averageData{sensorID,g}).^2;
        end
        correctedStd = sqrt(varianceEstimator) ./ (n-1.5);
        stdevData{sensorID,g} = correctedStd;
    end
end

%% Load the trigger times
triggerPath = '/Users/goocy/Documents/141212 Status Dohorap/Experiment/Dohorap/Speech/';
triggerFiles = {[triggerPath 'offsets_der.txt'], [triggerPath 'offsets_den.txt']};
triggerData = [];
for i = 1:2
    triggerData = [triggerData; importdata(triggerFiles{i})];
end


%% Plot the whole thing

conditionColors = [[0.6 0 0]; [0 0 1]];
timescale = -1.0:0.001:4.0;
xText = 'Time after condition trigger in s';
yText = {'Evoked field activity in fT', 'Evoked RMS activity in fT/cm'};
sensorText = {'magnetometer', 'gradiometer'};
conditionText = {'Object-relative clauses', 'Subject-relative clauses'};
groupText = {'children', 'adults'};
metrics = {'ERF', 'RMS activity'};

% Prepare sensor layout
sensorPositions = zeros(306,3);
for i = 1:306
    sensorPositions(i,:) = epoch.info.chs(i).coil_trans(1:3,4);
end
[ttheta,tphi,~]=cart2sph(sensorPositions(:,1),sensorPositions(:,2),sensorPositions(:,3));
[sensorsX,sensorsY]=pol2cart(ttheta,pi/2-tphi);

scalings = {1e15, 1e13};
xlims = [-0.5, 2.5];
layoutPositions = {[0.6 0.2 0.35 0.35], [0.05 0.62 0.35 0.35]};
for sensID = [2, 1]
    sensors = sensorText{sensID};
    scaling = scalings{sensID};
    for g = 1:numel(groups)
        group = groups{g};
        % Determine maximal amplitude
        ylims = [min(averageData{sensID,g}(:)), max(averageData{sensID,g}(:));] * 1.1 * scaling;
        if sensID == 2; ylims(1) = 0; end
        for d = 1:numel(directions)
            direction = directions{d};
            for l = 1:numel(locations)
                location = locations{l};
                f = figure();

                % Design the main line plot
                plotSub = axes('Parent',f,'Position',[0.1 0.25 0.8 0.7]);
                hold(plotSub,'all');
                set(plotSub,'ColorOrder', distinguishable_colors(10));
                set(plotSub,'Box', 'on', 'LineWidth', 2);
                titleText = ['Grand average ' metrics{sensID} ' in ' direction '-' location ' ' sensors 's'];
                aData = zeros(2,5001);
                for c = 1:numel(conditions)
                    condition = conditions{c};
                    color = conditionColors(c,:);
                    a = squeeze(averageData{sensID,g}(c,d,l,:))' * scaling;
                    s = squeeze(stdevData{sensID,g}(c,d,l,:))' * scaling;
                    % Plot the filled charts
                    xFill = [-2, timescale, 6, fliplr(timescale), -2];
                    yFill = [0, a-s, 0, fliplr(a+s), 0];
                    fill(xFill, yFill, color, 'EdgeColor', 'None', 'FaceAlpha', 0.2);
                    aData(c,:) = a;
                end
                % Plot the line charts
                p = plot(timescale, aData, 'LineWidth', 2);
                for i=1:2; set(p(i), 'Color', conditionColors(i,:)); end;
                
                % Plot decorators
                xlim(xlims);
                ylim(ylims);
                title(titleText);
                ylabel(yText{sensID}); xlabel(xText);
                leg = legend(p, conditionText{1}, conditionText{2}, 'Location', 'NorthEast');
                set(leg, 'LineWidth',2);
                posAxes = get(plotSub, 'Position');

                % Overlay the sensor layout
                eval(['channelSelection = ' direction '_' location '_' sensortypes{sensID} '+1;']);
                layoutSub = axes('Parent',f, 'Position', layoutPositions{sensID});
                scatter(sensorsX(allMags), sensorsY(allMags),'Marker','o', 'Parent', layoutSub);
                hold(layoutSub,'all');
                scatter(sensorsX(channelSelection), sensorsY(channelSelection), 'MarkerFaceColor','r', 'Parent', layoutSub);
                set(layoutSub, 'DataAspectRatio', [1 1 1]);
                set(layoutSub, 'Color', 'None');
                set(layoutSub, 'Visible', 'off');

                % Overlay the sentence trigger
                triggerSub = axes('Parent',f);
                set(triggerSub, 'Box', 'on', 'LineWidth', 2);
                set(triggerSub, 'Position', [0.1 0.07 0.8 0.04]);
                set(triggerSub, 'Color', [1 1 1]);
                hold(triggerSub, 'all');
                for i = 1:length(triggerData)
                    t = triggerData(i);
                    w = 0.001;
                    X = [t-w,t-w,t+w,t+w];
                    Y = [0,1,1,0];
                    patch(X,Y,[0 0 0],'EdgeColor','None','Parent',triggerSub,'FaceAlpha',0.3);
                end
                xlabel('End of sentence');
                hold(triggerSub,'off');
                xlim(xlims);
                set(triggerSub, 'XTick', []);
                set(triggerSub, 'YTick', []);

                % Save the result
                filename = [groupText{g} ' - comparison of ' direction '-' location ' ' sensors ' activity'];
                savefig(f, [filename '.fig']);
                print(f, [filename '.png'], '-dpng');
                close(f);
            end
        end
    end
end