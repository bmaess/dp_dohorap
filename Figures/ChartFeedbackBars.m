doPlot = false;

figure;
for medianRT = 1500:100:8000;
    if medianRT == 1500, hold on, end
    speedMedian = 2000.0 / medianRT;
    if speedMedian > 1.0; speedMedian = 1.0; end;
    speedBar = floor(612.0 * speedMedian);
    speedColorGreen = speedMedian;
    if (speedColorGreen > 1.0); speedColorGreen = 1.0; end;
    speedColor = [1.0-speedColorGreen, speedColorGreen, 0.2];
    h = bar(medianRT, speedBar/6, 100, 'FaceColor', speedColor, 'EdgeColor',speedColor);
    xlim([1500, 8000]);
    ylim([0,100]);
end

figure;
for accuracy = 50:100
    if accuracy == 50, hold on, end
    accuracyBar = 12.0 + 600*((19/5)*(accuracy/100 - 14/19));
    if accuracyBar < 12; accuracyBar = 12; end;
    accuracyColorGreen = (accuracyBar - 12.0)/600.0;
    accuracyColor = [1.0-accuracyColorGreen, accuracyColorGreen, 0.2];
    h = bar(accuracy, accuracyBar/6, 1, 'FaceColor', accuracyColor, 'EdgeColor',accuracyColor);
    xlim([50,100]);
    ylim([0,100]);
end