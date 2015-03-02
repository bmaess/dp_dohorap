clear;
% load('/scr/kuba1/Dohorap/Main/Data/MEG/motionCorrected/ResponseTimes.mat'); % loads RT
load('ResponseTimes.mat');
% rtMid = response - midSentence
% rtSound = response - soundOnset
subjectIDs{1} = [2:10, 12:19]; % kids
subjectIDs{2} = 52:71; % adults
subjectColors = {[0 0.6 0], [0 0 1]};

plotHist = false;
plotAccuracy = false;
plotBox = true;

correctnessSplit = cell(2,2);
correctnessIndividual = cell(2,2);
AverageRT = cell(2,2);
MedianRT = cell(2,2);
RTsplit = cell(2,2);
RTlinearGrouped = cell(1,2);
sortedMedian = cell(1,2);

for group = 1:2
    for subject = subjectIDs{group}
        trialsSkipped = RT{1,subject}(:,10) == 1;
        subjectRT = RT{1,subject}(:,7);
        trialsTooLong = subjectRT > prctile(subjectRT, 90);
        trialsInvalid = trialsSkipped | trialsTooLong;
        correctness = RT{1,subject}(:,11);

        conditionRT = RT{1,subject}(:,17);
        subjectRT(trialsInvalid) = [];
        conditionRT(trialsInvalid) = [];
        correctness(trialsInvalid) = [];

        RTlinearGrouped{group} = [RTlinearGrouped{group}; subjectRT];
        for condition = 1:2;
            MedianRT{group, condition} = [MedianRT{group, condition}, median(subjectRT(conditionRT==condition))];
            AverageRT{group, condition} = [AverageRT{group, condition}, mean(subjectRT(conditionRT==condition))];
            RTsplit{group,condition} = [RTsplit{group,condition}; subjectRT(conditionRT==condition)];
            correctnessSplit{group, condition} = [correctnessSplit{group, condition}; correctness(conditionRT==condition)];
            correctnessIndividual{group, condition} = [correctnessIndividual{group, condition}, mean(correctness(conditionRT==condition))];
        end;
    end;
end;
RTsize = cellfun(@length, RTsplit);
minRTsize = min(min(RTsize));
RTsample = zeros(4,minRTsize);
correctnessSize = cellfun(@length, correctnessSplit);
minCorrectnessSize = min(min(correctnessSize));
correctnessSample = zeros(4,minCorrectnessSize);
for group = 1:2
    for condition = 1:2
        RTsample((group-1)*2 + condition,:) = randsample(RTsplit{group, condition}./1000, minRTsize);
        correctnessSample((group-1)*2 + condition,:) = randsample(correctnessSplit{group, condition}./1000, minCorrectnessSize);
    end;
end;
maxRT = prctile(RTsample(:),99);
clear correctness subjectRT conditionRT trialsSkipped trialsTooLong trialsInvalid condition group

if plotHist
    %% plot histogram of both populations
    [nelements,centers] = hist([RTsample(1,:),RTsample(2,:);RTsample(3,:),RTsample(4,:)]',100);
    f = figure(); b = bar(centers,nelements);
end
if plotAccuracy
    %% Display trial correctness by reaction time
    averagingWindow = 80;
    timescale = 0:max([ max(RTlinearGrouped{1}) , max(RTlinearGrouped{2}) ]);
    accuracyGrouped = [];
    accuracyConditioned = [];
    accuracySplit = cell(2,2);
    for group = 1:2;
        for condition = 1:2;
            RTandCorrectness = [RTsplit{group, condition}, correctnessSplit{group, condition}];
            RTandCorrectnessSorted = sortrows(RTandCorrectness,1);
            uniqueRTandCorrectnessSorted = unique(RTandCorrectnessSorted(:,1));
            % Average all accuracies per unique reaction time
            accuracyRT = [];
            for singleRT = uniqueRTandCorrectnessSorted'
                currentIndices = find(RTandCorrectnessSorted(:,1) == singleRT);
                accuracyRT = [accuracyRT; [singleRT, mean(RTandCorrectnessSorted(currentIndices,2))] ];
            end;
            clear RTandCorrectness RTandCorrectnessSorted uniqueRTandCorrectnessSorted currentIndices
            % Spread the reaction times across a continuous timescale
            accuracyLinear = interp1(accuracyRT(:,1)',accuracyRT(:,2)',timescale);
            % Smooth the result
            accuracySmoothed = smoothts(accuracyLinear, 'b', averagingWindow);
            accuracySplit{group,condition} = [accuracySplit{group,condition}; accuracySmoothed(1,:)];
        end;
        accuracyGrouped(group,:) = mean([accuracySplit{group,1}; accuracySplit{group,2}]);
    end;
    for condition = 1:2
        accuracyConditioned(condition,:) = mean([accuracySplit{1,condition}; accuracySplit{2,condition}]);
    end;
    clear group condition RTandCorrectnessSorted accuracyRT accuracyLinear accuracySmoothed singleRT
    f = figure(); p = plot(timescale/1000,accuracyGrouped);
    set(get(f,'CurrentAxes'),'PlotBoxAspectRatio', [2 1 1]);
    title('Accuracy for response times between groups');

    % Boxplots
    RTlinearMat = NaN(length(RTlinearGrouped),max(cellfun('length',RTlinearGrouped)));
    for i = 1:length(RTlinearGrouped); RTlinearMat(i,1:length(RTlinearGrouped{i})) = RTlinearGrouped{i}; end;
    hold on; b = boxplot(RTlinearMat'./1000,'orientation','horizontal'); xlim([0, 4]); ylim([0,1]);
    for group = 1:size(b,2);
        % Scale boxplots vertically down to 25%
        for i = 1:size(b,1); set(b(i,group),'YData', get(b(i, group),'YData').*0.25); end;
        % Set the colors for both plots
        set(p(group),'Color',subjectColors{group});
        set(b(5,group),'Color',subjectColors{group});
    end;
    clear currentRT currentAccuracy correctRTsorted datapoint group i lastRT sampleSize subject tempAccuracy
end

%% Test the two groups and two conditions
logFileName = 'ComparisonStatistics.txt';
logFileID = fopen(logFileName,'w');

groupText = {'Children', 'Adults'};
significanceText = {'', 'slightly ', 'much '};
testText = {'Average', 'Median'};
accuracyText = {'less', 'more', 'equally'};
midText = {' than ', ' as in ' ' as '};
RTtext = {'faster', 'slower'};
unit = {'', 'ms'};

for test = 1:2
    % Combine the datasets according to effect
    if test == 1
        fprintf(logFileID, '\nComparison of correctness\n');
        firstCondition = [correctnessIndividual{1,1}, correctnessIndividual{2,1}];
        secondCondition = [correctnessIndividual{1,2}, correctnessIndividual{2,2}];
    elseif test == 2
        fprintf(logFileID, '\nComparison of median RT\n');
        firstCondition = [MedianRT{1,1}, MedianRT{2,1}];
        secondCondition = [MedianRT{1,2}, MedianRT{2,2}];
    %elseif test == 3
    %    fprintf(logFileID, '\nComparison of average RT\n');
    %    firstCondition = [AverageRT{1,1}, AverageRT{2,1}];
    %    secondCondition = [AverageRT{1,2}, AverageRT{2,2}];
    end
    data = [firstCondition, secondCondition];
    conditionAssociations = [ones(1,length(firstCondition)), ones(1,length(secondCondition))*2];
    lengths = [length(AverageRT{1,1}),length(AverageRT{2,1})];
    groupAssociations = [ones(1,lengths(1)), ones(1,lengths(2))*2, ones(1,lengths(1)), ones(1,lengths(2))*2];
    associations = {conditionAssociations, groupAssociations};
    firstGroupMean = mean(data(groupAssociations==1));
    secondGroupMean = mean(data(groupAssociations==2));
    fprintf(logFileID, ['Condition values: ' num2str(mean(firstCondition)) ' (Subject-first), ' num2str(mean(secondCondition)) ' (Object-first)\n']);
    fprintf(logFileID, ['Group values: ' num2str(firstGroupMean) ' (Children), ' num2str(secondGroupMean) ' (Adults)\n']);
    if lillietest(data) == 0
        fprintf(logFileID, 'ANOVA results: \n');
        [p, table, stats] = anovan(data, associations, 'model', 'full', 'display', 'off');
        fprintf(logFileID, ['Condition effect: p = ' num2str(p(1)) ', F = ' num2str(table{2,6}) '\n']);
        fprintf(logFileID, ['Group effect: p = ' num2str(p(2)) ', F = ' num2str(table{3,6}) '\n']);
        fprintf(logFileID, ['Interaction effect: p = ' num2str(p(3)) ', F = ' num2str(table{4,6}) '\n\n']);
    else
        fprintf(logFileID, 'Nonlinear test results: \n');
        stats = mwwtest(data(conditionAssociations==1), data(conditionAssociations==2));
        fprintf(logFileID, ['Condition effect: p = ' num2str(stats.p) ', z = ' num2str(stats.z) '\n']);
        stats = mwwtest(data(groupAssociations==1), data(groupAssociations==2));
        fprintf(logFileID, ['Group effect: p = ' num2str(stats.p) ', z = ' num2str(stats.z) '\n']);
    end
end

for group = 1:2
    for test = 1:2
        if test == 1
            fprintf(logFileID, ['\nComparison of correctness in ' groupText{group} '\n']);
            firstCondition = correctnessIndividual{group,1};
            secondCondition = correctnessIndividual{group,2};
        elseif test == 2
            fprintf(logFileID, ['\nComparison of median RT in ' groupText{group} '\n']);
            firstCondition = MedianRT{group,1};
            secondCondition = MedianRT{group,2};
        %elseif test == 3
        %    fprintf(logFileID, ['\nComparison of average RT in ' groupText{group} '\n']);
        %    firstCondition = AverageRT{group,1};
        %    secondCondition = AverageRT{group,2};
        end
        data = [firstCondition; secondCondition];
        fprintf(logFileID, 'ANOVA results: \n');
        [p, table, stats] = anova1(data', [], 'off');
        fprintf(logFileID, ['Condition values: ' num2str(mean(firstCondition)) ' (Subject-first), ' num2str(mean(secondCondition)) ' (Object-first)\n']);
        fprintf(logFileID, ['Condition effect: F = ' num2str(table{2,6}) ', p = ' num2str(p(1)) '\n']);
    end
end
fclose(logFileID);

%% Display boxplots of RT
if plotBox
    conditionLabels = {{'Children (Subject first)', 'Children (Object first)'}, {'Adults (Subject first)', 'Adults (Object first)'}};
    f = figure();
    for group = 1:2
        s = subplot(2,1,group);
        firstCondition = MedianRT{group,1};
        secondCondition = MedianRT{group,2};
        data = [firstCondition; secondCondition];
        b = boxplot(data', conditionLabels{group}, 'orientation','horizontal', 'colorgroup', [group-1 group-1]);
        xlim([0, maxRT*1000]);
        for condition = 1:2
            set(b(5, condition),'Color',subjectColors{group});
        end;
        %set(s, 'PlotBoxAspectRatio', [2.5 1 1]);
    end;
    title('Reaction times between groups and conditions');
end