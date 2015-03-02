function slowTrials = rejectLowPerformers(trials, upperCutOffPercentage)
    subjectRT = trials(:,7);
    correctness = trials(:,11);
    trialsSkipped = trials(:,10);
    trialsPremature = trials(:,12);
    trialsInvalid = ~correctness | trialsSkipped | trialsPremature;
    threshold = prctile(subjectRT,upperCutOffPercentage);
    slowTrials = ~((subjectRT < threshold) & ~trialsInvalid);
end