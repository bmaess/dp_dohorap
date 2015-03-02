function events = readEventFile(fifFilePath)
    pathElements = strsplit(fifFilePath,'/');
    path = [strjoin(pathElements(1:end-1),'/'), '/'];
    fifFileNameElements = strsplit(pathElements{end},'_');
    eveFileNames = dir([path fifFileNameElements{1} '*.eve']);
    % select the shortest event file
    if size(eveFileNames,1) > 1
        shortestFileName = 1;
        for i = 2:size(eveFileNames,1);
            if size(eveFileNames(i,1).name,2) < size(eveFileNames(shortestFileName,1).name,2)
                shortestFileName = i;
            end;
        end;
        eveFileName = eveFileNames(shortestFileName,1).name;
    else
        eveFileName = eveFileNames.name;
    end;
    
    % load the event file
    eveFile = importdata([path '/' eveFileName]);
    if iscell(eveFile)
        error ('No standard .eve file found. Please run mne_writeevents first.');
    end;
    if size(eveFile,1) == 1
        eveFile = eveFile.data;
    end;
    
    % restructure to fieldtrip structure
    events = [];
    offset = eveFile(1,1);
    eveFile(1,:) = [];
    for i = 1:size(eveFile,1)
        events(i,1).type = 'STI101';
        if ~iscell(offset)
            events(i,1).sample = eveFile(i,1) - offset;
        else
            events(i,1).sample = eveFile(i,1);
        end;
        events(i,1).value = eveFile(i,4);
        events(i,1).offset = [];
        events(i,1).duration = [];
    end;
end