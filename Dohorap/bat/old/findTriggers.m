function [trl, event] = findTriggers(cfg)
    % read the header information and the events from the data
    trl = [];
    hdr   = ft_read_header(cfg.dataset);
    event = ft_read_event(cfg.dataset);

    % search for trigger events
    value  = [event(find(strcmp('STI101', {event.type}))).value]';
    sample = [event(find(strcmp('STI101', {event.type}))).sample]';
    for code = 1:length(value)
        if value(code) > 16384
            value(code) = value(code) - 16384;
        elseif value(code) > 8192 && value(code) < 16384
            value(code) = value(code) - 8192;
        elseif value(code) > 4096 && value(code) < 8192
            value(code) = value(code) - 4096;
        end;
    end;

    % allow 0.5 second of data before and after the trigger
    pretrig  = -round(0.5 * hdr.Fs);
    posttrig =  round(0.5 * hdr.Fs);

    trialCodes = cell(1);
    trialTimes = cell(1);
    t = 0;
    % restructure the linear 'values' list into a structured cell array named 'trials'
    for j = 1:(length(value)-1)
      eventCode = value(j);
        if eventCode < 80 % search for picture codes to find the start of a trial
            t = t + 1;
            trialCodes{t}.picture = eventCode;
            trialTimes{t}.picture = sample(j);
            trialCodes{t}.sound = 0;
            trialCodes{t}.earlySentence = 0;
            trialCodes{t}.midSentence = 0;
            trialCodes{t}.response = 0;
        end;
        if t > 0
            if any(cfg.eventtype == eventCode) % search for the sound code
                trialCodes{t}.sound = eventCode;
                trialTimes{t}.sound = sample(j);
            end;
            if eventCode == 101
                trialCodes{t}.earlySentence = 1;
                trialTimes{t}.earlySentence = sample(j);
            end;
            if eventCode == 102 
                trialCodes{t}.midSentence = eventCode;
                trialTimes{t}.midSentence = sample(j);
            end;
            if eventCode >= 4096 % save the last response code
                trialCodes{t}.response = eventCode;
                trialTimes{t}.response = sample(j);
            end;
            trialCodes{t}.prematureResponse = trialCodes{t}.midSentence == 0;
            trialCodes{t}.trialSkipped = trialCodes{t}.response == 16384;
            trialCodes{t}.responseCorrect = (any(trialCodes{t}.sound == [212 222]) && trialCodes{t}.response == 8192) || (any(trialCodes{t}.sound == [211 221]) && trialCodes{t}.response == 4096);
        end;
    end;
    for t = 1:size(trialCodes,2)
        if trialCodes{t}.sound > 0 && trialCodes{t}.picture > 0 && trialCodes{t}.midSentence > 0 && trialCodes{t}.response > 0
            if strcmp(cfg.triggertype, 'onset')
                trlbegin = trialTimes{t}.sound + pretrig;
                trlend = trialTimes{t}.response + posttrig;
            elseif strcmp(cfg.triggertype, 'feedback')
                trlbegin = trialTimes{t}.response + pretrig;
                if t+1 > size(trialCodes,2) % end of file?
                    trlend = sample(len(sample));
                else
                    trlend = trialTimes{t+1}.picture + posttrig;
                end;
            elseif strcmp(cfg.triggertype, 'decision')
                trlbegin = trialTimes{t}.sound + pretrig;
                trlend = trialTimes{t}.response + posttrig;
            end;
            offset = pretrig;
            rtMid = trialTimes{t}.response - trialTimes{t}.midSentence;
            rtSound = trialTimes{t}.response - trialTimes{t}.sound;
            mid = trialTimes{t}.midSentence - trialTimes{t}.sound;
            newtrl = [trlbegin trlend offset trialCodes{t}.picture trialCodes{t}.sound trialCodes{t}.response rtMid mid rtSound trialCodes{t}.trialSkipped trialCodes{t}.responseCorrect trialCodes{t}.prematureResponse];
            trl = [trl; newtrl];
        end;
    end;
    filename = [cfg.datafile '-behavioral-' cfg.triggertype '.mat'];
    save(filename, 'trl');
end