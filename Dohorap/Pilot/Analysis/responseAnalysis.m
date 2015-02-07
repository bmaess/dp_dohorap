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
responseTime = cell(1, subjectCount);
subjectWord = cell(1, subjectCount);
verbWord = cell(1, subjectCount);
objectWord = cell(1, subjectCount);
subjectID = cell(1, subjectCount);
medianRT = zeros(1,subjectCount);
accuracy = zeros(1,subjectCount);
for s = 1:subjectCount
    r = responses{s};
    validTrials = r(4,:) == 1;
    trialIDs = r(1,validTrials);
    offsets = trialIDoffsets(trialIDs);
    responseTime{s} = r(2,validTrials) - offsets;
    responseSide{s} = r(5,validTrials);
    subjectWord{s} = r(6,validTrials);
    verbWord{s} = r(7,validTrials);
    objectWord{s} = r(8,validTrials);
    subjectID{s} = ones(1,sum(validTrials))*s;
    condition{s} = (trialIDs <= 152)+1;
    
    % Behavioral data
    accuracy(s) = mean(r(4,:));
    medianRT(s) = median(responseTime{s});
end
clear r validTrials offsets s
validSubjects = accuracy >= 0.8;

responseTimeL = [];
responseSideL = [];
subjectWordL = [];
verbWordL = [];
objectWordL = [];
conditionL = [];
for s = 1:subjectCount;
    if validSubjects(s)
        responseTimeL = [responseTimeL, responseTime{s}];
        responseSideL = [responseSideL, responseSide{s}];
        subjectWordL = [subjectWordL, subjectWord{s}];
        verbWordL = [verbWordL, verbWord{s}];
        objectWordL = [objectWordL, objectWord{s}];
        conditionL = [conditionL, condition{s}];
    end
end
clear s
mainEffects = anovan(responseTimeL, {responseSideL subjectWordL verbWordL objectWordL});
