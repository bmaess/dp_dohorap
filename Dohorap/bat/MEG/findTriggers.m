function [trl, events] = findTriggers(cfg)
    header   = ft_read_header(cfg.dataset); % read the header information from the .fif file
    events   = readEventFile(cfg.dataset); % reading the simplest .eve file instead of parsing the .fif datastream
    
    % search for trigger events
    eventValues  = [events(strcmp('STI101', {events.type})).value]';
    eventSamples = [events(strcmp('STI101', {events.type})).sample]';
    %% Use the presentation logfile data to extract the correct conditions
    s = sprintf('%02i',cfg.subject);
    block = char(64+cfg.block);
    presentationEvents = extractPresentationEvents([cfg.PresentationPath '/dh' s 'a/'], ['dh' s 'a-main' block '*.log'], cfg.dataPath);
    eventFileName = [cfg.dataset(1:end-4) '-corrected.eve'];
    [eventValues, eventTrials] = correctPresentationConditions(eventFileName, presentationEvents, eventValues, eventSamples, eventSamples/header.Fs);
    clear s block presentationEvents;
    
    %% Cluster the events into structured trials and correct each condition code with the Presentation data
    trialCount = sum(unique(eventTrials) ~= 0);
    pictureCodes = -ones(1,trialCount);  pictureTimes = -ones(1,trialCount);
    soundCodes = -ones(1,trialCount);    soundTimes = -ones(1,trialCount);
    decisionTimes = -ones(1,trialCount); soundEndTimes = -ones(1,trialCount);
    responseCodes = -ones(1,trialCount); responseTimes = -ones(1,trialCount);
    trial = 0; responseGiven = 0;
    for event = 1:(length(eventValues))
        e = eventValues(event);
        events(event).trial = eventTrials(event);
        if e <= 76 % New trial detected: reset response flag
            if eventTrials(event) ~= 0
                trial = eventTrials(event);
                responseGiven = 0;
                pictureCodes(trial) = e;
                pictureTimes(trial) = eventSamples(event);
            end;
        end;
        if trial > 0
            if any(e == cfg.eventtype) % Sentence onset
                soundCodes(trial) = e;
                soundTimes(trial) = eventSamples(event);
            elseif e == 101 % Mid-sentence ('Wo ist das Tier das |der Affe fängt')
                decisionTimes(trial) = eventSamples(event);
            elseif e == 102 % Late-sentence ('Wo ist das Tier das der Affe fäng|t')
                soundEndTimes(trial) = eventSamples(event);
            elseif any(e == [4096, 8192, 16384]) % Response onset
                if responseGiven == 0 % save only the first response
                    responseCodes(trial) = e;
                    responseTimes(trial) = eventSamples(event);
                    responseGiven = 1;
                end;
            end;
        end;
    end;
    
    %% Calculate additional data
    correctText = {'Correct ', 'Incorrect ', 'Premature ', 'Incorrect and premature ', 'Skipped ', 'Skipped ', 'Prematurly skipped ', 'Prematurly skipped '};
    conditions = extractDigit(soundCodes(soundCodes ~= -1), 2);
    conditionText = {'Den-Condition', 'Der-Condition'};
    correctSides = extractDigit(soundCodes(soundCodes ~= -1), 3);
    correctSideText = {'Left is correct', 'Right is correct'};
    responseButtons = (responseCodes(soundCodes ~= -1) == 4096) + 2 * (responseCodes(soundCodes ~= -1) == 8192) + 3 * (responseCodes(soundCodes ~= -1) == 16384);
    responseButtonLabels = {'Left button', 'Right button', 'Skip button'};
    skippedTrials = responseCodes(soundCodes ~= -1) == 16384;
    
    prematureReponses = responseTimes < decisionTimes;
    wrongSides = responseButtons ~= correctSides;
    wrongResponses = bi2de([wrongSides', prematureReponses', skippedTrials'],0);
    earlyDecision = (responseTimes < soundEndTimes);
    earlyDecisionText = {'Normal decision', 'Early decision'};
    
    soundRT = responseTimes - soundTimes;
    decisionRT = responseTimes - decisionTimes;
    
    invalidPictures = (pictureCodes == -1) & (pictureTimes == -1);
    invalidDecisions = (decisionTimes == -1);
    invalidSounds = (soundCodes == -1) & (soundTimes == -1);
    invalidResponses = (responseCodes == -1) & (responseTimes == -1);
    invalidTrials = invalidPictures & invalidDecisions & invalidSounds & invalidResponses;
    
    %% Write data to enhanced logfile (and to the fieldtrip array)
    eventFileName = [cfg.dataset(1:end-4) '-enhanced.eve'];
    eventFileID = fopen(eventFileName, 'w');
    fprintf(eventFileID, '# Sample Time 0 EventCode Trial Explanation\n');
    fclose(eventFileID); eventFileID = fopen(eventFileName, 'a');
    outString = '%6i %04.3f 0 %i %i %s\n';
    timeWindow  = round(0.5 * header.Fs);
    
    trl = [];
    for trial = 1:trialCount
        if ~invalidTrials(trial)
            w = wrongResponses(trial);
            % Picture codes
            fprintf(eventFileID, outString, pictureTimes(trial), pictureTimes(trial)/header.Fs, 100 + w, trial, 'Onset Picture');
            fprintf(eventFileID, outString, pictureTimes(trial), pictureTimes(trial)/header.Fs, pictureCodes(trial), trial, 'Picture ID');
            
            % Sentence codes
            fprintf(eventFileID, outString,   soundTimes(trial),   soundTimes(trial)/header.Fs, 200 + w, trial, 'Onset Sound');
            c = conditions(trial); 
            fprintf(eventFileID, outString,   soundTimes(trial),   soundTimes(trial)/header.Fs, 400 + 10 * c, trial, conditionText{c});
            cS = correctSides(trial);
            fprintf(eventFileID, outString,   soundTimes(trial),   soundTimes(trial)/header.Fs, 500 + 10 * cS, trial, correctSideText{cS});
            
            % Decision codes
            eD = earlyDecision(trial)+1;
            fprintf(eventFileID, outString,decisionTimes(trial),decisionTimes(trial)/header.Fs, 300 + w, trial, earlyDecisionText{eD});
            
            % Response codes
            RTtext = [correctText{w+1} sprintf('response after %i ms', decisionRT(trial))];
            fprintf(eventFileID, outString,responseTimes(trial),responseTimes(trial)/header.Fs, 600 + w, trial, RTtext);
            rS = responseButtons(trial);
            fprintf(eventFileID, outString,responseTimes(trial),responseTimes(trial)/header.Fs, 600 + 10 * rS, trial, responseButtonLabels{rS});
            
            % Trial array
            trialBorders = [0,0];
            switch cfg.triggertype
                case 'onset'
                    trialBorders = [soundTimes(trial) - timeWindow, responseTimes(trial) + timeWindow];
                case 'decision'
                    trialBorders = [decisionTimes(trial) - timeWindow, responseTimes(trial) + timeWindow];
                case 'feedback'
                    trialEnd = min(responseTimes(trial) + timeWindow + 4000, eventSamples(end)); % in case the file ends before 4000ms are complete
                    trialBorders = [responseTimes(trial) - timeWindow, trialEnd];
            end;            
            dL = decisionTimes(trial) - soundTimes(trial);
            newtrl = [trialBorders -timeWindow pictureCodes(trial) soundCodes(trial) responseCodes(trial) decisionRT(trial) dL soundRT(trial) skippedTrials(trial) ~wrongSides(trial) prematureReponses(trial) pictureTimes(trial) soundTimes(trial) decisionTimes(trial) responseTimes(trial)];
            trl = [trl; newtrl];
        else
            fprintf(eventFileID, outString, pictureTimes(trial), pictureTimes(trial)/header.Fs, 999, trial, 'Invalid trial');
        end;
    end;
    filename = [cfg.dataset(1:end-4) '-behavioral-' cfg.triggertype '.mat'];
    save(filename, 'trl');
end
