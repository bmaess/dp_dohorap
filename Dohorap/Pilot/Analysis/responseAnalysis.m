clear

% load time offsets
triggerFile = importdata('/Users/goocy/Documents/141222 Dissertation/Dohorap/Pilot/Experiment/Speech/cues.txt');
trialCount = numel(triggerFile);
trialIDoffsets = [];
for i = 1:trialCount
    t = triggerFile{i};
    rawParts = regexp(t, ' ', 'split');
    parts = cell(1,1);
    p = 1;
    for rp = 1:numel(rawParts)
        if ~isempty(rawParts{rp})
            parts{p} = rawParts{rp};
            p = p+1;
        end
    end
    if strcmp(parts{3}(1:2),'mi')
        offset = str2double(parts{1});
        trigger = parts{3}(1:3);
        wavfile = str2num(parts{5}(1:3));
        trialIDoffsets(wavfile) = offset;
    end
end
clear i rawParts parts p rp offset trigger wavfile triggerFile t

% load response, responseList, words
load('responseData.mat');
subjectCount = numel(responses);
medianRT = zeros(1,subjectCount);
accuracy = zeros(1,subjectCount);
careless = zeros(2,subjectCount);
ratio = zeros(1,subjectCount);
conditionalAccuracy = zeros(2, subjectCount);
for s = 1:subjectCount
    r = responses{s};
    trialIDs = r(1,:);
    offsets = trialIDoffsets(trialIDs);
    rawRT = r(2,:) - offsets;
    validTrials = r(4,:) == 1 & rawRT > 0;
    validTrialIDs = trialIDs(validTrials);
    responseTime{s} = rawRT(validTrials);
    responseSide{s} = r(5,validTrials);
    subjectWord{s} = r(6,validTrials);
    verbWord{s} = r(7,validTrials);
    objectWord{s} = r(8,validTrials);
    subjectID{s} = ones(1,sum(validTrials))*s;
    condition{s} = (validTrialIDs <= 152) +1;
    
    % Behavioral data
    accuracy(s) = mean(r(4,:));
    medianRT(s) = median(responseTime{s});
    [pRandom, pciRandom] = binofit(round(size(r,2)/2), size(r,2), 0.01);
    careless(1,s) = accuracy(s) < pciRandom(2);
    secondConditionTrials = (r(1,:) >= 152);
    firstConditionTrials = (r(1,:) <= 152);
    conditionCount{s} = [sum(firstConditionTrials), sum(secondConditionTrials)];
    conditionalAccuracy(1,s) = mean(r(4,firstConditionTrials));
    conditionalAccuracy(2,s) = mean(r(4,secondConditionTrials));
    [pRandom, pciRandom] = binofit(round(sum(firstConditionTrials)/2), sum(firstConditionTrials), 0.01);
    careless(2,s) = conditionalAccuracy(1,s) < pciRandom(2);
    ratio(s) = sum(firstConditionTrials) / sum(secondConditionTrials);
end
clear r offsets s

responseTimeL = [];
responseSideL = [];
subjectWordL = [];
verbWordL = [];
objectWordL = [];
conditionL = [];
for s = 1:subjectCount;
    if ~careless(2,s)
        responseTimeL = [responseTimeL, log(responseTime{s})];
        responseSideL = [responseSideL, responseSide{s}];
        subjectWordL = [subjectWordL, subjectWord{s}];
        verbWordL = [verbWordL, verbWord{s}];
        objectWordL = [objectWordL, objectWord{s}];
        conditionL = [conditionL, condition{s}];
    end
end
clear s

[~,accuracyP,accuracyCI,accuracyStats] = ttest(conditionalAccuracy(1,~careless(1,:)), conditionalAccuracy(2,~careless(1,:)));
[rtP, rtTable, rtStats] = anovan(responseTimeL, {responseSideL, subjectWordL, verbWordL, objectWordL, conditionL});