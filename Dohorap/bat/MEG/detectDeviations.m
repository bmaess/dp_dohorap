function trialsWithArtifacts = detectDeviations(epochs, suffix, channels, timeWindow, rejectionThreshold, doDraw)
    
    trialCount = length(epochs.trial);
    [trialLength, longestTrial] = max(cellfun(@length, epochs.trial));
    channelCount = length(channels);

    emptyData = ones(1,timeWindow)/timeWindow;
    criticalTimeBorders = zeros(trialCount,2);
    trialsWithArtifacts = zeros(channelCount, trialCount);
    criticalData = [];
    trialColor = [];

    pictureTime = 10; soundTime = 11; decisionTime = 12; responseTime = 13;
    for t = 1:trialCount
        switch suffix
            case 'onset'; criticalTimeSlot = [epochs.trialinfo(t,pictureTime) epochs.trialinfo(t,responseTime)];
            case 'feedback'; criticalTimeSlot = [epochs.trialinfo(t,responseTime) epochs.sampleinfo(t,2)]; 
            case 'decision'; criticalTimeSlot = [epochs.trialinfo(t,decisionTime) epochs.trialinfo(t,responseTime)];
        end;
        epoch = epochs.trial{1,t}(channels,:);
        averagedEpoch = filter(emptyData, 1, epoch, [], 2); % moving average filter
        averagedEpochPower = filter(emptyData, 1, epoch.^2, [], 2);
        deviation = abs(sqrt(averagedEpochPower - averagedEpoch.^2)); % standard deviation from the average (result befor the sqrt can get smaller than zero, hence the abs)
        deviation = [deviation(:, 1+ceil(timeWindow/2):end) NaN(channelCount,ceil(timeWindow/2))]; % correction for filter time lag

        criticalTimeSlot = criticalTimeSlot - epochs.sampleinfo(t,1);
        criticalTimeBorders(t,:) = criticalTimeSlot;
        if any(not(criticalTimeSlot < 1)); % skip obviously invalid trials
            criticalDeviation = deviation(:,criticalTimeSlot(1):criticalTimeSlot(2));
            artifactedChannels = any(criticalDeviation' > rejectionThreshold);
            trialsWithArtifacts(:,t) = artifactedChannels;
            artifactPresent = any(artifactedChannels);
            % no artifacts detected? throw in a few random channels
            if ~artifactPresent
                artifactedChannels(ceil(rand(1,3)*channelCount))=1;
                trialColor = [trialColor, zeros(1,sum(artifactedChannels))];
            else
                trialColor = [trialColor, ones(1,sum(artifactedChannels))];
            end;
            fillBlock = NaN(sum(artifactedChannels),trialLength-size(deviation,2));
            criticalDataBlock = [deviation(artifactedChannels,:) fillBlock];
            criticalData = [criticalData; criticalDataBlock];
        end;
    end;
    
    if doDraw
        colors = [0 0.4 0; 0.8 0 0];
        color = colors(trialColor+1,:);
        mainPlot = figure();
        medianCriticalBorders = round(median(criticalTimeBorders));
        line(epochs.time{longestTrial}(1,medianCriticalBorders), [rejectionThreshold, rejectionThreshold], 'Color', [0 0 0]);
        plot_butterfly(epochs.time{longestTrial}, criticalData, color);
        xlim(epochs.time{longestTrial}(1,[1, medianCriticalBorders(2)])*1.2);
        pathParts = strsplit(epochs.hdr.orig.raw.info.filename,'/');
        fileParts = strsplit(pathParts{end},'.');
        subjectParts = strsplit(fileParts{1},'_');
        fileName = [getenv('DOCDIR') '/Rejection/' subjectParts(1) '-' suffix '-' num2str(timeWindow) 'ms.png'];
        print(mainPlot, strjoin(fileName,''), '-dpng');
        close(mainPlot);
    end;
end