function writeEnhancedEventFileHeader(eventFileName)
    eventFileID = fopen(eventFileName, 'w');
    fprintf(eventFileID, '# Event code 1-76: Picture\n');
    fprintf(eventFileID, '# Event code 211/212/221/222: Sentence onset\n');
    fprintf(eventFileID, '# Event code 201: Mid-sentence marker\n');
    fprintf(eventFileID, '# Event code 202: End-sentence marker\n');
    fprintf(eventFileID, '# Event code 4096/8192/16384: Response\n\n');
    fprintf(eventFileID, '# Sample Time  0 EventCode\n');
    fclose(eventFileID);
end