function eventTrials = readCorrectedEventFile(eventFileName)
    f = fopen(eventFileName);
    t = textscan(f,'%s %f %d %d %d %s %*[^\n]','HeaderLines',1);
    eventTrials = t{5};
end