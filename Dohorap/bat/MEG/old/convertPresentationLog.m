logfiles = dir('*.log');
for file = 1:size(logfiles,1)
    filename = logfiles(file).name;
    if strfind(filename, 'main') > 0
        log = importPresentationLog(filename);
        loglen = size(log,2);
        outfile = fopen(horzcat(filename(1,1:end-4), '.txt'),'w');
        for trial = 1:loglen
            time = log(1,trial).time;
            ttime = log(1,trial).ttime;
            t = log(1,trial).trial;
            code = log(1,trial).code;
            desc = log(1,trial).event_type;
            fprintf(outfile,  '%i %i %i %3s %s \n', time, ttime, t, code, desc);
        end;
    end;
end;