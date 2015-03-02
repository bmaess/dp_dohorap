clear;

gradfactor = 1e13;
magfactor = 1e15;
gradlimit = [-150 150];
maglimit  = [-120 120];

% MEGpath = '/Users/goocy/Documents/MEG';
MEGpath = '/SCR/Dohorap/Main/Data/MEG';
        
% for subject = [1:11 51:63]
for subject = 55;
    for trigger = 3
        if trigger == 1
            suffix = 'onset';
        elseif trigger == 2
            suffix = 'feedback';
        elseif trigger == 3
            suffix = 'decision';
        end;
        
        prefix = ['/dh' num2str(subject,'%02i') 'a/dh' num2str(subject,'%02i') 'a-l12h0.4'];
        filename = [MEGpath prefix '-' suffix '.mat'];
        load (filename);
        
        h = figure('name',['Time-locked ' suffix ' for subject ' num2str(subject,'%02i')]);
        set(h,'paperunits','centimeters');
        set(h,'papersize',[32, 10.8]);
        set(h,'paperposition',[0,0,32,10.8]);
        averageMags = cell(1,2);
        mags = find(sum(epochs.hdr.grad.tra,2)==1);
        magStrength = zeros(size(mags));
        magVariation = zeros(size(mags));
        for condition = 1:2
            if condition == 1
                stimulusCodes = [211 212];
            elseif condition == 2
                stimulusCodes = [221 222];
            end;
            for trial = 1:size(epochs.trialinfo,1)
                codeSelection(trial) = any(epochs.trialinfo(trial, 2) == stimulusCodes);
            end;
            cfg = [];
            cfg.removemean = 'yes';
            cfg.vartrllength = 2;
            cfg.trials = codeSelection;
            avgData = ft_timelockanalysis(cfg,epochs);
            avgMag = avgData.avg(mags,:);
            if condition == 1
                timescale = avgData.time;
            end;
            if size(timescale,2) > size(avgData.time,2) % take the shorter timescale
                timescale = avgData.time;
            end;
            magStrength = magStrength + max(abs(avgMag(:,500:2000)'))';
            magVariation = magVariation + var(avgMag(:,500:2000),0,2);
            
            averageMags{condition} = avgData.avg(mags,:);
        end;
        [~,strongestMags] = sort(magStrength./magVariation);
        for channel = 1:4
            samplescale = 1:size(timescale,2);
            meanMag = [averageMags{1}(strongestMags(channel),samplescale); averageMags{2}(strongestMags(channel),samplescale)];
            subplot(2,2,channel);
            plot(timescale, meanMag * magfactor);
            xlim ([-0.2 0.8]); ylim (maglimit*1.5);
            title (['Channel ' avgData.label{mags(strongestMags(channel))}]);
            xlabel ('time'); ylabel ('field amplitude (fT)');
            legend('forward', 'reverse', 'Location', 'NorthEast');
        end;
        print(h, ['../doc/fieldtripAverage/' num2str(subject,'%02i') 'a-conditionContrast-' suffix '.png'],'-dpng')
    end;
end;