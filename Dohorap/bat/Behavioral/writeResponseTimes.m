clear;

suffix = 'decision';
basePath = '/SCR/Dohorap/Main/Data/';
% basePath = '/Users/goocy/Documents/';
MEGpath = [basePath 'MEG/motionCorrected/'];
RT = cell(1,71);

for subject = [2:19 52:71];
    s = ['dh' num2str(subject,'%02i') 'a'];
   
    RT{subject} = [];
    for block = 1:2
        trl = [];
        load ([MEGpath s '/' s num2str(block) '_mc-behavioral-' suffix '.mat']);
        for trial = 1:size(trl,1)
            inCode = trl(trial,5)-200;
            condition = round(inCode/10);
            responseSide = inCode - condition*10;
            RT{subject} = [RT{subject}; [trl(trial,:), condition, responseSide]];
        end;
    end;
    dlmwrite([MEGpath s '/BehavioralData.txt'], RT{subject}, 'precision', 12);
end;
save([MEGpath 'ResponseTimes.mat'], 'RT');