function trialsWithArtifacts = rejectDeviations(epochs, trigger, channels, timeWindow, rejectionThreshold)
    pictureTime = 10; soundTime = 11; decisionTime = 12; responseTime = 13;
    emptyData = ones(1,timeWindow)/timeWindow;
    trialCount = length(epochs.trial);
    trialsWithArtifacts = zeros(1,trialCount);
    
    for t = 1:trialCount
        switch trigger
            case 1; criticalTimeSlot = [epochs.trialinfo(t,pictureTime) epochs.trialinfo(t,responseTime)];
            case 2; criticalTimeSlot = [epochs.trialinfo(t,responseTime) epochs.sampleinfo(t,2)]; 
            case 3; criticalTimeSlot = [epochs.trialinfo(t,decisionTime) epochs.trialinfo(t,responseTime)];
        end;
        criticalTimeSlot = criticalTimeSlot - epochs.sampleinfo(t,1);
        epoch = epochs.trial{1,t}(channels,:);
        averagedEpoch = filter(emptyData, 1, epoch, [], 2); % moving average filter
        deviation = sqrt(filter(emptyData, 1, epoch.^2, [], 2) - averagedEpoch.^2); % standard deviation from the average
        deviation = [deviation(1+ceil(timeWindow/2):end) zeros(1,ceil(timeWindow/2))]; % correction for filter time lag
        trialsWithArtifacts(t) = any(deviation(criticalTimeSlot(1):criticalTimeSlot(2)) > rejectionThreshold);
    end;
end