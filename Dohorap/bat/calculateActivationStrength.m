averagePath = '/Volumes/Dohorap/Dohorap/Main/Data/MEG_mc_hp004_ica_l50/';
dirEntries = dir(averagePath);
subjectList = cell(1,2);
for i = 1:size(dirEntries,1)
    if length(dirEntries(i).name) == 5
        subjectID = str2num(dirEntries(i).name(3:4));
        if subjectID > 50
            subjectList{2} = [subjectList{2}; dirEntries(i).name];
        else
            subjectList{1} = [subjectList{1}; dirEntries(i).name];
        end
    end
end

mags = 3:3:306;
grads = sort([1:3:304, 2:3:305]);

scaling = 1e15;
averageActivity = cell(2,2);
for group = 1:numel(subjectList)
    subjects = subjectList{group};
    for subjectIndex = 1:size(subjects,1)
        subject = subjects(subjectIndex,:);
        evokedFilename = [averagePath subject '/Feed_average-ave.fif'];
        if exist(evokedFilename, 'file')
            evokedFile = fiff_read_evoked(evokedFilename);
            evokedData = evokedFile.evoked.epochs;
            gradActivity = median(abs(evokedData(grads,:)));
            magActivity = median(abs(evokedData(mags,:)));
            averageActivity{group,1} = [averageActivity{group,1}; gradActivity];
            averageActivity{group,2} = [averageActivity{group,2}; magActivity];
        end
    end
end