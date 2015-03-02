function compareLocalizedTrials
    timeslotLength = 20;
    load('LocalizedTrials.mat')
    trialLengths = cellfun(@(x) size(x,2), PAC);
    sigDiff = zeros(7,max(trialLengths)-timeslotLength);
    for roi = 1:7
        o = 1; s = 1;
        objectFirstTrials = {};
        subjectFirstTrials = {};
        
        for trial = 1:304
            switch roi
                case 1, trialData = BA44{trial};
                case 2, trialData = BA45{trial};
                case 3, trialData = Opercular{trial};
                case 4, trialData = PAC{trial};
                case 5, trialData = aSTG{trial};
                case 6, trialData = pSTG{trial};
                case 7, trialData = parsorbitalis{trial};
            end;
            diffLength = max(trialLengths) - size(trialData,2);
            if extractDigit(conditions{trial},2) == 1
                objectFirstTrials{o} = [trialData NaN(1,diffLength)];
                o = o+1;
            else
                subjectFirstTrials{s} = [trialData NaN(1,diffLength)];
                s = s+1;
            end;
        end;
        clear o s trial diffLengths
        objectFirstTrials = cell2mat(objectFirstTrials');
        subjectFirstTrials = cell2mat(subjectFirstTrials');

        trialCount = min([size(objectFirstTrials,1), size(subjectFirstTrials,1)]);
        iterations = 10;
        increasedTrialCount = trialCount * iterations;
        differenceTrials = zeros(trialCount * iterations, max(trialLengths));
        for datapoint = 1:max(trialLengths)
            o = objectFirstTrials(:,datapoint);
            s = subjectFirstTrials(:,datapoint);
            b = bootstrp(iterations, @difference, o,s);
            differenceTrials(:,datapoint) = b(:);
            clear b;
        end;
        comparisonTime = max(trialLengths)-timeslotLength;
        differenceMean =     zeros(increasedTrialCount, comparisonTime);
        differenceVariance = zeros(increasedTrialCount, comparisonTime);
        %window = repmat(hann(timeslotLength+1), 1, increasedTrialCount)';

        for timeStart = 1:comparisonTime
            timeEnd = timeStart + timeslotLength;
            differenceFragment = differenceTrials(:,timeStart:timeEnd);
            differenceMean(:,timeStart) = nanmean(differenceFragment,2);
            differenceVariance(:,timeStart) = nanvar(differenceFragment,0,2);
        end;
        differenceVariance(differenceVariance == 0) = NaN;
        t = customTtest(differenceMean, differenceVariance, size(differenceTrials,1));
        sigDiff(roi,:) = mean(t > 2.4);
    end;
    plot(sigDiff');
    xlim([1,2200]);
    legend('BA44','BA45', 'Opercular', 'PAC', 'aSTG', 'pSTG', 'parsorbitalis');
    
    function t = customTtest(d,variance,n)
        t = sqrt((d.^2)./(variance./n));
    end

    function d = difference(a,b)
        d = a-b;
    end
end    