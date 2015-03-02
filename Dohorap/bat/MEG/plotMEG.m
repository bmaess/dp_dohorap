function plotMEG(data, subject, channelString)
    if isnumeric(subject)
        subject = [num2str(subject,'%02i'), 'a'];
    end;
    switch channelString
        case 'mags'; channelSelection = find(sum(data.hdr.grad.tra,2)==1);
        case 'grads'; channelSelection = find(sum(data.hdr.grad.tra,2)<1);
        case 'all'; channelSelection = ones(1,306);
    end;
    numChannels = length(channelSelection);
    numTrials = size(data.trial,2);
    trialStrength = cellfun(@(x) median(abs(x),2), data.trial, 'UniformOutput', false);
    channelStrength = median(cell2mat(trialStrength),2);
    channelNormalizing = 0.2./median(channelStrength(channelSelection));
    h = figure;
    set(h,'paperunits','centimeters');
    set(h,'papersize',[numTrials*5, numChannels/2]);
    set(h,'paperposition',[0,0,numTrials*3,numChannels/3]);
    set(h,'InvertHardCopy', 'off');
    channelHeight = 1:numChannels;
    thisPlot = cell(1,numTrials);
    trialSize = zeros(1,numTrials);
    verticalLinesX = zeros(2,numTrials);
    for n = 1:numTrials
        trialSize(1,n) = size(data.trial{1,n}(channelSelection,:),2); 
        channelOffset = repmat(channelHeight', 1, trialSize(1,n));
        thisPlot{1,n} = data.trial{1,n}(channelSelection,:).*channelNormalizing + channelOffset;
        verticalLinesX(:,n) = [sum(trialSize(1,1:n)), sum(trialSize(1,1:n))];
    end;
    clear data;
    plot(cell2mat(thisPlot)');
    ylim([0,numChannels+1]);
    hold on;
    verticalLinesY = repmat([0; numChannels+1], 1, numTrials);
    line(verticalLinesX, verticalLinesY);
    print(h, [getenv('DOCDIR') '/MEG/' subject '.png'],'-dpng','-r100');
    close(h)