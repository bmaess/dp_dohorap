function [logicalRej, timeRej] = meeg_artefact_rejection_std(data, sfreq, winTime, threshold)

% [logicalRej timeRej] = meeg_artefact_rejection_std(data, sfreq, winTime, threshold)
%
% Obligatory input:
%	data  - channels x time
%	sfreq - sampling frequency
%
% Optional inputs (defaults):
%	winTime   = 200; % sliding window in ms
%	threshold = 80e-6; % maximal threshold
%
% Output:
%	logicalRej - logical index vector of rejected samples
%	timeRej    - time epochs that included rejected samples
%
% Description: The program marks artefacts of a signal (rawdata or epochs). It provides 
% a logical index vector where a one marks a rejected sample, using the standard 
% deviation within a certain time window as criteria.
% ------------------------------------------------------------------------------
% B.Herrmann, B.Maess; Email: bherrmann@cbs.mpg.de; 2011-02-11 

% load some defaults if appropriate
logicalRej = []; timeRej = [];
nInputs = nargin;
if nInputs < 1, fprintf('Error: data needs to be defined.\n'); return; end
if nInputs < 2, fprintf('Error: sfreq needs to be defined.\n'); return; end
if nInputs < 3 || isempty(winTime), winTime = 200; end
if nInputs < 4 || isempty(threshold), threshold = 80e-6; end

% get time window in samples
winSamples = sfreq * winTime / 1000;
emptyData = ones(1,winSamples)/winSamples;

% compute standard deviation for the sliding window
meanVals   = filter(emptyData, 1, data, [], 2);
stdVals    = sqrt(filter(emptyData, 1, data.^2, [], 2) - meanVals.^2);

% find bad samples
badsamples = sum(stdVals > threshold,1) > 0;

% shift the filtered signal (badsamples) back by half the filter length
badsamples = [badsamples(1+ceil(winSamples/2):end) zeros(1,ceil(winSamples/2))];

% get time bins to be rejected
badStartEnd = diff([0 badsamples(1:end-1) 0]);
samplesRej  = [find(badStartEnd == 1); find(badStartEnd == -1)]';
timeRej     = (samplesRej-1) * 1000/sfreq;
logicalRej  = badsamples;

return;

