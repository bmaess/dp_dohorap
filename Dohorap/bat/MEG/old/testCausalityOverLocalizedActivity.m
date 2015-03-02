
% Convert python output into EEGLAB fomrat
load('LocalizedTrials.mat');
trialCount = numel(conditions);
areaNames = {'BA44','BA45','Opercular','PAC','aSTG','pSTG','parsorbitalis'};
testConnections = [1 6; 6 1; 2 6; 6 2; 1 2; 2 1; 4 6; 6 4; 4 7; 7 4];
testData = permute(cat(3, collapse(BA44), collapse(BA45), collapse(Opercular), collapse(PAC), collapse(aSTG), collapse(pSTG), collapse(parsorbitalis)),[3 2 1]);
conditionList = cellfun(@(x) extractDigit(x,2), conditions);
data = {};
EEG = [];
for c = 1:2
    conditionTrials = conditionList == c;
    EEG(c).data = testData(:,:,conditionTrials);
    EEG(c).trials = sum(conditionTrials);
    EEG(c).pnts = size(testData,2);
    EEG(c).srate = 1000;
    EEG(c).xmin = 0;
    EEG(c).xmax = EEG(c).pnts / EEG(c).srate;
    EEG(c).times = (1:EEG(c).pnts) ./ EEG(c).srate;
    EEG(c).setname = num2str(c);
    EEG(c).condition = num2str(c);
end;