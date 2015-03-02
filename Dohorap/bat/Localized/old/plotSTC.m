addpath('/scr/kuba2/Matlab/fieldtrip_120925/external/mne');
localizedPath = '/scr/kuba2/Dohorap/Main/Data/Localized_avg/';
docPath = '/scr/kuba2/Dohorap/Main/Data/doc/ROIactivity/';
ROIs = {'PAC','pSTS','aSTG','BA6','BA44','BA45','V1'};
conditions = {'Feed','Obj','Subj','Vis'};
ROIselection = {[1,2,5],[1:6],[1:6],[1,2,7]};
timescale = -0.8:0.001:3.199;

hemispheres = {'lh','rh'};
subjectList = dir(localizedPath);
for subjectIndex = 1:numel(subjectList)
    subject = subjectList(subjectIndex).name;
    if numel(subject) > 2
        if strcmp('dh', subject(1:2))
            for conditionIndex = 1:numel(conditions)
                condition = conditions{conditionIndex};
                for hemisphereIndex = 1:numel(hemispheres)
                    hemisphere = hemispheres{hemisphereIndex};
                    activity = cell(1,1);
                    activityFile = [localizedPath subject '/' condition '-' hemisphere '.mat'];
                    d = load(activityFile);
                    % Print activity over all ROIs for this condition
                    plotFile = [docPath 'ROIactivity/' subject '/' condition '-' hemisphere '.png'];
                    f = figure;
                    plot(timescale, data);
                    xlim([-0.5, 1.8]);
                    legend(ROIs);
                    lh=findall(gcf,'tag','legend');
                    lp=get(lh,'position');
                    set(lh,'position',[0.0,lp(2),lp(3:4)]);
                    pbaspect([2.5 1 1]);
                    title(['Localized power for condition ' condition ' in hemisphere ' hemisphere]);
                    print(f, '-dpng', '-r300', plotFile);
                    close(f);
                end
            end
        end
    end
end