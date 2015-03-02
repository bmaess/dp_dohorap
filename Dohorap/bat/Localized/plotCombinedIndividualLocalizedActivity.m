addpath('/scr/kuba2/Matlab/fieldtrip_120925/external/mne');
localizedPath = '/scr/kuba2/Dohorap/Main/Data/Localized_avg/';
docPath = '/scr/kuba2/Dohorap/Main/Data/doc/ROIactivity/';
ROIs = {'PAC','pSTS','aSTG','BA6r','BA44','BA45'};
conditions = {'Obj','Subj'};
colors = {'b','r'};
timescale = -1.0:0.001:2.999;
hemispheres = {'lh','rh'};

% Determine individual subject folders
entries = dir(localizedPath);
subjects = cell(1,1);
subjectIndex = 1;
for entryIndex = 1:size(entries,1)
    entry = entries(entryIndex,1).name;
    if numel(entry) > 2
        if strcmp(entry(1:2),'dh')
            subjects{subjectIndex} = entry;
            subjectIndex = subjectIndex + 1;
        end
    end
end

% Load activity file into the variable ROIactivity
dataLength = size(timescale,2);
hemisphereCount = numel(hemispheres);
roiCount = numel(ROIs);
subjectCount = numel(subjects);
conditionCount = numel(conditions);
ROIactivity = zeros(hemisphereCount, roiCount, subjectCount, conditionCount, dataLength);

for hemisphereIndex = 1:hemisphereCount
    hemisphere = hemispheres{hemisphereIndex};
    
    for roiIndex = 1:roiCount
        ROI = ROIs{roiIndex};
        
        for subjectIndex = 1:subjectCount
            subject = subjects{subjectIndex};
            
            for conditionIndex = 1:conditionCount
                condition = conditions{conditionIndex};
                
                activityFile = [localizedPath subject '/' condition '_norm-' hemisphere '.mat'];
                d = load(activityFile, ROI);
                eval(['data = d.' ROI ';']);
                ROIactivity(hemisphereIndex, roiIndex, subjectIndex, conditionIndex,:) = data;
            end;
        end;
    end;
end;

% Plot the data
for hemisphereIndex = 1:hemisphereCount
    hemisphere = hemispheres{hemisphereIndex};
    plotFile = [docPath hemisphere '_norm.png'];
    f = figure;
    pbaspect([2.5 1 1]);
    title(['Power comparison between conditions in hemisphere ' hemisphere]);
    
    for roiIndex = 1:roiCount
        ROI = ROIs{roiIndex};
        subplot(2,3,roiIndex);
        title(['Activity in region ' ROI]);
        hold on;
        
        for subjectIndex = 1:subjectCount
            
            for conditionIndex = 1:conditionCount
                subjectActivity = mean(squeeze(ROIactivity(hemisphereIndex, roiIndex, subjectIndex, :,:)),1);
                data = squeeze(ROIactivity(hemisphereIndex, roiIndex, subjectIndex, conditionIndex,:));
                normalizedData = data / mean(subjectActivity);
                %patchline(timescale, normalizedData, 'Edgecolor', colors{conditionIndex}, 'Edgealpha', 0.15);
                fill([timescale(1); timescale'; timescale(end)], [0; normalizedData; 0], colors{conditionIndex}, 'FaceAlpha', 0.10, 'EdgeAlpha', 0.0);
                pbaspect([2.5 1 1]);
                disp([hemisphereIndex, roiIndex, subjectIndex, conditionIndex]);
                xlim([-0.5, 1.8]);
            end
        end
        hold off;
    end
    
    % Include a legend
    legend(conditions);
    lh=findall(gcf,'tag','legend');
    lp=get(lh,'position');
    set(lh,'position',[0.0,lp(2),lp(3:4)]);
    print(f, '-dpng', '-r300', plotFile);
    close(f);
end