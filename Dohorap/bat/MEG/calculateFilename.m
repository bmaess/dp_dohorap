function outfile = calculateFilename(rawfile, s)
    rawFileParts = strsplit(rawfile,'/');
    rawFileName = strsplit(rawFileParts{end},'.');
    rawFileName{1} = [rawFileName{1} s];
    rawFileParts{end} = strjoin(rawFileName,'.');
    outfile = strjoin(rawFileParts, '/');
end