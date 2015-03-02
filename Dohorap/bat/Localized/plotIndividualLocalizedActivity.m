addpath('/scr/kuba2/Matlab/fieldtrip_120925/external/mne');
localizedPath = '/scr/kuba2/Dohorap/Main/Data/Localized_avg/';
docPath = '/scr/kuba2/Dohorap/Main/Data/doc/';
ROIs = {'PAC','pSTS','aSTG','BA6r','BA44','BA45'};
conditions = {'Obj','Subj'};
hemispheres = {'lh','rh'};
colors = {'b','r'};
timescale = -1.0:0.001:2.999;

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

doPlot = 0;
dataLength = length(timescale);
for subjectIndex = 1:numel(subjects)
    subject = subjects{subjectIndex};
    subjectID = str2double(subject(3:4));
    plotPath = [docPath 'ROIactivity/'];
    for roiIndex = 1:numel(ROIs)
        ROI = ROIs{roiIndex};
        
        for hemisphereIndex = 1:numel(hemispheres)
            hemisphere = hemispheres{hemisphereIndex};
            
            plotFile = [plotPath subject '-' ROI '-' hemisphere '.png'];
            f = figure;
            hold on;
            for conditionIndex = 1:numel(conditions)
                disp([subjectIndex, roiIndex, hemisphereIndex, conditionIndex]);
                condition = conditions{conditionIndex};
                color = colors{conditionIndex};
                activityFile = [localizedPath subject '/' condition '_norm-' hemisphere '.mat'];
                d = load(activityFile);
                eval(['ROIactivity = d.' ROI ';']);
                % Print activity over all ROIs for this condition
                xScale = [timescale(1), timescale, timescale(end)];
                yScale = [0, ROIactivity', 0];
                fill(xScale, yScale, color, 'FaceAlpha', 0.5, 'EdgeAlpha', 0);
            end
            hold off;
            xlim([-0.5, 1.8]);
            % add a legend
            legend(conditions);
            lh=findall(gcf,'tag','legend');
            lp=get(lh,'position');
            set(lh,'position',[0.0,lp(2),lp(3:4)]);
            pbaspect([2.5 1 1]);
            title(['Localized power for ROI ' ROI ' in hemisphere ' hemisphere]);
            print(f, '-dpng', '-r300', plotFile);
            close(f);
        end
    end
end