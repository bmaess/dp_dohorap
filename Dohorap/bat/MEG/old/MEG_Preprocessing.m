function MEG_Preprocessing(s, suffix, recreate, paths, do)
if do.rejectLowPerformers
    folderComment = '-quick';
else
    folderComment = '';
end;
averageEpochsName = [paths.MEG s s suffix folderComment '-averageEpochs.mat'];
averageFifFileStem = [paths.MEG s s suffix folderComment '-averageEpochs'];
covFileStem = [paths.MEG s s 'covariance'];

if exist(averageEpochsName,'file') && recreate.averageData == 0
    disp(['Loading averaged epochs from subject ' num2str(subject)]);
    load(averageEpochsName); % loads avgData
else
    epochs, cfg = rejectEpochs(paths, s, suffix, recreate);
end

if recreate.fifFiles
    writeAverageFif(averageConditions, averageFifFileStem);
    writeCovarianceMatrix(averageConditions, covFileStem);
end;
clear epochs;

if do.print == 1
    FieldtripTopoPlot(averageOverall, subject, suffix, folderComment)
end;

end
