% ./MEG/summarizeRejectedTrials.m
% -------------------------------
% Process: Save the results of the EOG/Jump rejection step
% Input: EXPDIR/dh58a/dh58a1_ss-rejectionLists.mat
% Output:
% - rejectedJumps.mat
% - rejectedEOGs.mat
% - rejectedTrialCount.mat
% Dependencies: none

clear;
subjects = [2:19 52:71];
rejectedJumpEpochs = cell(1,length(subjects));
rejectedEOGEpochs = cell(1,length(subjects));
for subject = subjects
	s = ['/dh' num2str(subject,'%02i') 'a'];
	for block = 1:2
		filename = ['.' s s num2str(block) '_ss-rejectionLists.mat'];
		load(filename);
		rejectedJumpEpochs{subject} = (sum(jumpEpochs)>0);
		rejectedEOGEpochs{subject} = EOGepochs;
		rejectedTrialCount(subject,block) = sum(rejectedJumpEpochs | EOGepochs);
	end;
end;
rejectedTrialCount = sum(rejectedTrialCount,2);
save('./rejectedJumps.mat', 'rejectedJumpEpochs');
save('./rejectedEOGs.mat', 'rejectedEOGEpochs');
save('./rejectedTrialCount.mat', 'rejectedTrialCount');
