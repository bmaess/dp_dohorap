function [correctedFifEvents, eventTrials] = correctPresentationConditions(outFileName, presentationEvents, fifEventValues, fifEventSamples, fifEventTimes)
    % Write out the corrected event log file
    writeEnhancedEventFileHeader(outFileName);
    eventFileID = fopen(outFileName, 'a');
    
    correctedFifEvents = fifEventValues;
    eventSize = length(fifEventValues);
    presentationIndices = 1; lastImageEvent = 0;
    eventTrials = zeros(1,eventSize);
    bigShift = 0; validTrial = [0,0,0,0];
    currentTrial = 1;
    for event = 1:eventSize
        eventCode = fifEventValues(event);
        if eventCode < 80
            if lastImageEvent > 0
                % New trial! If everything went fine, process the old trial now
                if ~bigShift && sum(validTrial) == 4
                    % Delete the old presentation log trial (so it can't be found the next time)
                    presentationEvents(:,1) = [];
                    eventTrials(lastImageEvent:event-1) = currentTrial;
                    currentTrial = currentTrial + 1;
                end;
            end;
            bigShift = 0; validTrial = [0,0,0,0];
            
            % Look up the current picture ID in the presentation log and extract the condition
            % Ideally, the two trial sequences would be identical.
            % We still use a "find" method to get the next best result if something is wrong in either event file.
            presentationTrialIndex = find(presentationEvents(1,:)==eventCode, 1, 'first');
            if ~isempty(presentationTrialIndex)
                validTrial(4) = 1; % found something
                presentationIndices = [presentationIndices, presentationTrialIndex];
                % Measure if the current entry was in a unusual position
                shiftAbnormality = presentationTrialIndex / median(presentationIndices);
                if shiftAbnormality > 2
                    disp(['Synchronization problem with event ' num2str(event) ': Image code ' num2str(eventCode) ' found ' num2str(presentationTrialIndex-1) ' slots behind the expected position in the presentation log!']);
                    bigShift = 1;
                end;
            else
                error(['Image code ' num2str(eventCode) ' for event ' num2str(event) ' not found in the presentation log!']);
            end;
            lastImageEvent = event;
        end;
            
        % Check if the required event codes exist
        switch eventCode
            case {211, 212, 221, 222}
                validTrial(1) = 1;
                condition = presentationEvents(3,presentationTrialIndex);
                eventCode = 200 + condition*10 + extractDigit(eventCode,3);
                correctedFifEvents(event) = eventCode;
            case 101
                validTrial(2) = 1;
            case {4096, 8192, 16384}
                validTrial(3) = 1;
        end;
        fprintf(eventFileID, '%6i %04.3f 0 %i\n', fifEventSamples(event), fifEventTimes(event), eventCode);
    end;
    
    % Check the correctness of the final trial
    if ~bigShift && sum(validTrial) == 4
        eventTrials(lastImageEvent:end) = currentTrial;
    end;
    correctedEvents = sum(fifEventValues ~= correctedFifEvents);
    if correctedEvents > 0
        disp(['Successfully corrected ' num2str(correctedEvents) ' events']);
    else
        disp(['No correction neccessary']);
    end;
end
