function presentationEvents = extractPresentationEvents(presentationPath, presentationFileStem, dataPath)

    presentationFileNames = dir([presentationPath presentationFileStem]);
    i = size(presentationFileNames,1);
    presentationLog = importPresentationLog([presentationPath, presentationFileNames(i,1).name]);
    presentationConditions = importdata([dataPath '/Dohorap/Main/Experiment/Pictures/ImageConditions.txt']);

    % Read the master file and extract soundcode and condition
    masterFile = [dataPath '/Dohorap/Main/Experiment/Speech/wavconditions.txt'];
    trials = importdata(masterFile);
    trialsSize = size(trials,1);
    masterEvents = zeros(4,trialsSize);
    for trial = 1:trialsSize
        eventLine = strsplit(trials{trial},';');
        imagecode = ceil(trial/4);
        trialcode = str2num(eventLine{3}(1:3));
        condition = 10*(strcmp(eventLine{4},'der')+1);
        masterEvents(1,trial) = imagecode;
        masterEvents(2,trial) = trialcode;
        masterEvents(3,trial) = condition;
    end;
    
    % Parse the presentation file, extract the subject's trialcodes and imagecodes
    presentationEvents = [];
    for e = 1:size(presentationLog,2)-1
        if strcmp(presentationLog(1,e).event_type,'Picture')
            presentationEvents(1,presentationLog(1,e).trial) = str2num(presentationLog(1,e).code);
            presentationEvents(4,presentationLog(1,e).trial) = presentationLog(1,e).trial;
        end;
        if strcmp(presentationLog(1,e+1).event_type,'Sound')
            presentationEvents(2,presentationLog(1,e+1).trial) = str2num(presentationLog(1,e+1).code);
        end;
    end;
    presentationEvents(:,presentationEvents(1,:) == 0) = []; 
    
    % Look up the condition for the trialcode
    invalidEvents = [];
    for e = 1:size(presentationEvents,2)
        if presentationEvents(2,e) >= 1 && presentationEvents(2,e) <= 304
            condition = presentationConditions(presentationEvents(2,e),2);
            % Do a sanity check against the imagecode
            imagecode = presentationConditions(presentationEvents(2,e),1);
            if imagecode == presentationEvents(1,e)
                presentationEvents(3,e) = condition;
            else
                error('Presentation logfile doesn''t agree with the master file.');
            end;
        else
            disp(['Incomplete Trial ' num2str(e) ' in the presentation logfile (image ' num2str(presentationEvents(1,e)) ', presentation log trial ' num2str(presentationEvents(4,e)) ') was excluded.']);
            invalidEvents = [invalidEvents,e];
        end;
    end;
    
    % Remove incomplete trials
    if ~isempty(invalidEvents)
        for i = 1:length(invalidEvents)
            presentationEvents(:,invalidEvents(i)) = [];
        end;
    end;
end