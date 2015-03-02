function fiff_filter_raw_data(cfg)

% fiff_filter_raw_data(cfg)
%
% Obligatory input:
%	cfg.rawfile = 'rawfile.fif';
%	cfg.outfile = 'outfile.fif';
%	cfg.filtvec = load('cfg/bp_010_20_1751pts_500Hz.coeff'); % needs to be a filter vector
%
% Optional input:
%	cfg.ch_idxs = 1:306; % channel indices to be filtered; takes all MEG channels as default
%	cfg.filter  = 'asy'; % asy - asymmetric, sym - symmetric
%
% Descrption: Filters the rawfile and writes a new file.
% Be careful, in the case of cfg.filter = 'asy' zeros (half of the filter length)
% are added at the end of the file, due to filtering.
% In the case of cfg.filter = 'sym' the filter becomes steeper.
% ---------------------------------------------------------------------------
% B. Herrmann, Email: bherrmann@cbs.mpg.de, 2010-03-19


% Load some defaults if appropriate
% ---------------------------------
FIFF = fiff_define_constants;
if ~isfield(cfg, 'rawfile'), fprintf('Error: cfg.rawfile needs to be defined.\n'); return; end
if ~isfield(cfg, 'outfile'), fprintf('Error: cfg.outfile needs to be defined.\n'); return; end
if ~isfield(cfg, 'filtvec'), fprintf('Error: cfg.filtvec needs to be defined.\n'); return; end
if ~isfield(cfg, 'ch_idxs'), cfg.ch_idxs = 1:306; end
if ~isfield(cfg, 'filter'),  cfg.filter  = 'asy'; end
if ~isfield(cfg, 'ds'),      cfg.ds      = 1; end


% Load data
% ---------
raw_in = fiff_setup_read_raw(cfg.rawfile);
% raw_in.last_samp = 120000;
data   = fiff_read_raw_segment(raw_in, raw_in.first_samp, raw_in.last_samp);

if  numel(cfg.filtvec)==max(size(cfg.filtvec)) % FIR filter
    filt_a = 1;
    filt_b = cfg.filtvec;
else % IIR filter
    if size(cfg.filtvec,1)>size(cfg.filtvec,2)
        filt_a = cfg.filtvec(:,2);
        filt_b = cfg.filtvec(:,1);
    else
        filt_a = cfg.filtvec(2,:);
        filt_b = cfg.filtvec(1,:);
    end
end

% Do the filtering of the raw data
% --------------------------------
fprintf(['Filtering raw data of ' cfg.rawfile ' ... ']);
if strcmp(cfg.filter, 'sym')
    fprintf(' forward & reverse ...');
	fdata = filtfilt(filt_b, filt_a, data(cfg.ch_idxs,:)');
	data(cfg.ch_idxs,:) = fdata';
elseif strcmp(cfg.filter, 'asy')
    fprintf(' forward only ...');
	fdata = filter(filt_b, filt_a, data(cfg.ch_idxs,:), [], 2);
	% Shift all data by half of the filter length
	% -----------------------------------------------------------------------
	halffilt = floor(length(cfg.filtvec)/2);
%     data = [zeros(size(data,1),halffilt) data];
%     data(:,end-halffilt+1:end) = [];
%     % Copy the filtered data back into the matrix
% 
%     data(cfg.ch_idxs,:) = fdata;
		
	% shift the data back to old position, delete halffilt samples  
    % at the beginning, fill zeros at the end
	% ----------------------------------------------------------------------
	fdata(:,1:halffilt) = [];
	data(cfg.ch_idxs,:) = [fdata zeros(size(fdata,1),halffilt)];
else
	fprintf('\nError: Wrong definition of cfg.filter.\n');
	return;
end
fprintf('done\n');
clear fdata;


% Get outfile ready
% -----------------
fprintf('Writing to %s\n',cfg.outfile);
raw_out = raw_in;
[outfid, cals] = fiff_start_writing_raw(cfg.outfile, raw_out.info);
raw_out.cals = cals;


% Set up the reading parameters
% -----------------------------
from        = raw_in.first_samp;
to          = raw_in.last_samp;
quantum_sec = 1; % process a second at a time
quantum     = ceil(quantum_sec*raw_in.info.sfreq);


% Do the writing
% --------------
first_buffer = true;
percent_step  = 2.0; % in percent
progress_bar  = 0;
for i=1:100
    if i >= progress_bar+10
        fprintf('%5d',i);
        progress_bar = progress_bar + 10;
    end
end
fprintf(' %s\n','%');
progress_bar  = 0;
for first = from:quantum:to
	last = first + quantum - 1; % in samples
	if last > to
		last = to;
	end
	
	if first_buffer
%		if first > 0
			fiff_write_int(outfid,FIFF.FIFF_DATA_SKIP,round(first/raw_in.info.sfreq)); % first
%		end
		first_buffer = false;
	end

	fiff_write_raw_buffer(outfid, data(:,first-raw_in.first_samp+1:last-raw_in.first_samp+1), cals);
    if (last-from)/(to-from+1)*100 >= progress_bar + percent_step
	    fprintf('.');
        progress_bar = progress_bar + percent_step;
    end
end
fiff_finish_writing_raw(outfid);
fprintf(' done.\n');

return;
