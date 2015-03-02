function plotButterfly(epochs, averageData, suffix, folderComment)
%% Configuration
    gradfactor = 1e13;
    magfactor = 1e15;
    selectedChannel = 52;
    gradlimits = [-180 180];
    maglimits  = [-180 180];
    timeSelection = [-0.5 2.5];
    
%% Logic
    mags = find(sum(epochs.hdr.grad.tra,2)==1);
    grads = find(sum(epochs.hdr.grad.tra,2)<1);
    
    avgSize = size(averageData.avg);
    avgActivity = zeros(avgSize);
    for channel = 1:avgSize(1)
        avgActivity(channel,:) = averageData.avg(channel,1:avgSize(2));
    end;
    
    % timeScales
    trialLengths = cellfun(@length, epochs.time);
    [longestTrialLength, longestTrial] = max(trialLengths);
    [shortestTrialLength, shortestTrial] = min(trialLengths);
    timeScale = epochs.time{longestTrial};
    sampleScale = epochs.hdr.Fs * timeScale;
    firstSample = find(sampleScale == round(timeSelection(1) * epochs.hdr.Fs));
    lastSample = find(sampleScale == round(timeSelection(2) * epochs.hdr.Fs));
    sampleSelection = firstSample: lastSample;
    tooShortTrials = find(trialLengths < lastSample);
    for trial = 1:length(tooShortTrials)
        trialID = tooShortTrials(trial);
        channelCount = size(epochs.trial{trialID},1);
        fillPart = NaN(channelCount, lastSample - trialLengths(trialID));
        epochs.trial{trialID} = [epochs.trial{trialID} fillPart];
    end;
    
%% Display
    grey = [0.8, 0.8, 0.8];
    black = [0, 0, 0];
    
    mainPlot = figure('Color',[0 0 0]);
    set(mainPlot,'paperunits','centimeters');
    set(mainPlot,'papersize',[32, 10.8]);
    set(mainPlot,'paperposition',[0,0,32,10.8]);
    set(mainPlot,'InvertHardCopy', 'off');
    for sensortype = 1:2
        % Averaged trial, all sensors
        sA = subplot(2,2,sensortype, 'Parent', mainPlot);
        grid (sA, 'on');
        set(sA, 'XColor', grey); set(sA, 'YColor', grey);
        xlim (timeSelection); xlabel (['time after ' epochs.cfg.triggertype ' point in ms'], 'Color', grey);
        if sensortype == 1
            plot_butterfly(timeScale(sampleSelection), avgActivity(mags,sampleSelection) * magfactor, black);
            sensorText = 'magnetometers';
            ylabel ('field amplitude (fT)', 'Color', grey); ylim (maglimits);
        else
            plot_butterfly(timeScale(sampleSelection), avgActivity(grads,sampleSelection) * gradfactor, black);
            sensorText = 'gradiometers';
            ylabel ('field gradient (fT/m)', 'Color', grey);  ylim (gradlimits);
        end;
        title (['Averaged trials over all ' sensorText], 'Color', grey);
        
        % All trials, one sensor
        sT = subplot(2,2,2+sensortype, 'Parent', mainPlot);
        grid(sT, 'on');
        set(sT, 'XColor', grey); set(sT, 'YColor', grey);
        xlim (timeSelection); xlabel (['time after ' epochs.cfg.triggertype ' point in ms'], 'Color', grey);
        if sensortype == 1
            channelData = cell2mat(cellfun(@(x) x(mags(selectedChannel),sampleSelection), epochs.trial, 'UniformOutput', false)');
            plot_butterfly(timeScale(sampleSelection), channelData*magfactor, black);
            channelText = epochs.label{mags(selectedChannel)};
            ylabel ('field amplitude (fT)', 'Color', grey); ylim(maglimits*4);
        else
            channelData = cell2mat(cellfun(@(x) x(grads(selectedChannel),sampleSelection), epochs.trial, 'UniformOutput', false)');
            plot_butterfly(timeScale(sampleSelection), channelData*gradfactor, black);
            channelText = epochs.label{grads(selectedChannel)};
            ylabel ('field gradient (fT/m)', 'Color', grey); ylim(maglimits*4);
        end;
        title (['All trials from channel ' channelText], 'Color', grey);
    end;
    
    graphPath = [getenv('DOCDIR') '/Butterfly' folderComment '/'];
    s = ['dh' num2str(epochs.cfg.subject,'%02i') 'a'];
    print(mainPlot, [graphPath s '-' suffix '.png'],'-dpng');
    close(mainPlot);
end