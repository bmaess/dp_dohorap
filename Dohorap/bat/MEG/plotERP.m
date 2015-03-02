function plotERP(averageData, validTrials, magChannels, gradChannels, suffix, folderComment)

    gradfactor = 1e13;
    magfactor = 1e15;
    colors = [0.6 0 0; 0 0.2 0.6];
    validTrialsText = num2str(validTrials);
    labels = averageData{1,1}.cfg.channel;
    timeLimits = [-0.5 1.5];
    fifFileParts = strsplit(averageData{1,1}.cfg.previous.dataset,'/');
    subject = fifFileParts{end-1};

    h = figure;
    set(h,'paperunits','centimeters');
    set(h,'papersize',[32, 10.8]);
    set(h,'paperposition',[0,0,32,10.8]);
    hold on;
    mags = sum(averageData{1,1}.grad.tra') == 1;
    grads = sum(averageData{1,1}.grad.tra') == 0;

    for condition = 1:2
        c = colors(condition,:);
        avgMag = averageData{1,condition}.avg(mags,:);
        avgGrad = averageData{1,condition}.avg(grads,:);
        timescale = averageData{1,condition}.time;

        % Overall power
        subplot(2,2,3);
        avgMagPower = sqrt(mean((avgMag * magfactor).^2));
        fill([-10,timescale,10], [0, avgMagPower,0], c, 'EdgeColor', c, 'FaceAlpha', 0.3); hold on;
        xlim (timeLimits);
        xlabel ('time');
        title (['Combined magnitude power over ' validTrialsText ' trials']);
        ylabel ('mean mag power (fT)');

        subplot(2,2,4);
        avgGradPower = sqrt(mean((avgGrad * gradfactor).^2));
        plot(timescale, avgGradPower, 'Color', c); hold on;
        fill([-10,timescale,10], [0, avgGradPower,0], c, 'EdgeColor', c, 'FaceAlpha', 0.3); hold on;
        xlim (timeLimits);
        xlabel ('time');
        title (['Combined gradient power over ' validTrialsText ' trials']);
        ylabel ('mean grad power (fT/cm)');

        % Single channels
        subplot(2,2,1);
        meanMag = mean(averageData{1,condition}.avg(magChannels,:),1) * magfactor;
        stdMag = mean(sqrt(averageData{1,condition}.var(magChannels,:)),1) * magfactor;
        % plotStd(stdMag,c); hold on;
        plot(timescale, meanMag, 'Color', c, 'LineWidth', 2.5); hold on;
        xlim (timeLimits);
        xlabel ('time');
        title (['Magnitude from pSTG-related channels over ' validTrialsText ' trials']);
        ylabel ('field amplitude (fT)');

        subplot(2,2,2);
        meanGrad = mean(averageData{1,condition}.avg(gradChannels,:),1) * gradfactor;
        stdGrad = mean(sqrt(averageData{1,condition}.var(gradChannels,:)),1) * gradfactor;
        % plotStd(stdMag,c); hold on;
        plot(timescale, meanGrad, 'Color', c, 'LineWidth', 2.5); hold on;
        xlim (timeLimits);
        xlabel ('time');
        title (['Gradient from pSTG-related channels over ' validTrialsText ' trials']);
        ylabel ('field amplitude (fT/cm)');
    end;
    legend('Object-relative clauses','Subject-relative clauses', 'Location', 'NorthOutside');
    hold off;
    print(h, [getenv('DOCDIR') '/fieldtripERP' folderComment '/' num2str(subject,'%02i') '-ft_avg-' suffix '.png'],'-dpng');
    close(h);
    
    function outputColor = lighterColor(inputColor, factor)
        if factor > 0
            w = factor * 2 -1;
            white = [w w w];
            outputColor = mean([inputColor; white])/factor;
        else
            outputColor = inputColor;
        end;
    end

    function plotStd(stdMag,c)
        firstNaN = find(isnan(stdMag),1,'first');
        if isempty(firstNaN); firstNaN = length(stdMag); end;
        xFill = [timescale(1:firstNaN-1), 10, fliplr(timescale(1:firstNaN-1))];
        yFill = [stdMag(1:firstNaN-1), 0, -fliplr(stdMag(1:firstNaN-1))./2];
        fill(xFill, yFill*2, lighterColor(c,4), 'EdgeColor', lighterColor(c,2));
        fill(xFill, yFill, lighterColor(c,3), 'EdgeColor', lighterColor(c,2));
    end
end