function visualizeIndividualRT(subject)
datdir = getenv('DATDIR');
load([datdir 'MEG_stats/ResponseTimes.mat']); % loads RT
% [begin end offset picturecode soundcode responsecode rtMid midTime rtSound trialSkipped responseCorrect prematureResponse Condition responseSide];
% rtMid = response - midSentence
% rtSound = response - soundOnset

red = [1 0 0];
global green;
green = [0 0.6 0];
yellow = [0.8 0.8 0.1];
white = [1 1 1];
titles = {'Object-relative clauses', 'Subject-relative clauses'};

subjectRT = RT{1,subject}(:,7);
trialsSkipped = RT{1,subject}(:,10);
correctness = RT{1,subject}(:,11);
trialsPremature = RT{1,subject}(:,12);
condition = RT{1,subject}(:,17);

%% plot sequential RT
errorColors = [red; yellow; white];
f = figure();
subplot(2,2,[1,2]);
title(['Sequential response times for subject ' num2str(subject)]);
% legend
hold on;
bar(1,1, 'FaceColor', green);
bar(1,2, 'FaceColor', red);
bar(1,3, 'FaceColor', yellow);
bar(1,3, 'FaceColor', white);
hold off; hold on;
legend('Correct', 'Incorrect', 'Skipped', 'Premature');
% combined plot
for trial=1:numel(subjectRT)
  b = bar(trial, subjectRT(trial));
  invalidity = [~correctness(trial), trialsSkipped(trial), trialsPremature(trial)];
  color = chooseColor(errorColors, invalidity);
  set(b, 'FaceColor', color)
end;
xlim([0, length(subjectRT)]);
hold off;
% conditional plots
invalidity = [~correctness, trialsSkipped, trialsPremature];
for c = 1:2
    subplot(2,2,2+c);
    title(titles{c});
    hold on;
    conditionalTrials = find(condition==c);
    for trial=1:numel(conditionalTrials)
        t = conditionalTrials(trial);
        b = bar(trial, subjectRT(t));
        color = chooseColor(errorColors, invalidity(t,:));
        set(b, 'FaceColor', color)
    end;
    percentageCorrect = mean(correctness(conditionalTrials),2);
    text(1,1,[num2str(percentageCorrect*100,'%.2g') '% correct'], 'Units', 'normalized', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right');
    xlim([0, length(conditionalTrials)]);
    hold off;
end;
print(f, [getenv('DOCDIR') '/Behavioral/linearRT-' num2str(subject,'%02i') '.png'],'-dpng');
close(f)
function outColor = chooseColor(colors, invalids)
    if sum(invalids) > 0
        for i = 1:3
            if invalids(i)
                outColor = colors(i,:);
            end;
        end;
    else
        outColor = green;
    end;
end
end