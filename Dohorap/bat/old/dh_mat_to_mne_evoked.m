
conditions = {'forward','reverse'};
% {'dh01a','dh02a','dh03a','dh04a','dh05a','dh06a','dh07a','dh08a','dh09a','dh10a','dh11a','dh12a','dh13a','dh14a','dh15a','dh16a','dh17a','dh18a','dh19a',
% 'dh51a','dh52a','dh53a','dh54a','dh55a','dh56a','dh57a','dh58a','dh59a','dh60a','dh61a','dh62a','dh63a','dh64a','dh65a','dh66a','dh67a','dh68a','dh69a','dh70a','dh71a'};
subjects = {'dh52a','dh53a','dh54a','dh55a','dh56a','dh57a','dh58a','dh59a','dh60a','dh61a','dh62a','dh63a','dh64a','dh65a','dh66a','dh67a','dh68a','dh69a','dh70a','dh71a'};

for subject=subjects
raw_header = fiff_setup_read_raw([ getenv('RAWDIR') subject{1} '/' subject{1} '1.fif' ]);

infile = [ getenv('RAWDIR') 'motionCorrected/' subject{1} '/' subject{1} '-l12h0.4-average-decision.mat'];

load( infile );
[fpath,fname,~] = fileparts(infile);

load([ fpath '/' subject{1} '-l12h0.4-decision.mat']);

nsamps = 2001;

MAGIDX=~cellfun('isempty',regexp(raw_header.info.ch_names,'MEG...1'))';
GRDIDX=~cellfun('isempty',regexp(raw_header.info.ch_names,'MEG...[23]'))';

%%
for c=1:numel(conditions)
mne_evoked.info               = raw_header.info;
mne_evoked.info.projs         = mne_evoked.info.comps;
mne_evoked.evoked.aspect_kind =  100;
mne_evoked.evoked.is_smsh     =    0;
mne_evoked.evoked.nave        = numel(epochs.time); % waer besser mit einer anderen Lösung
mne_evoked.evoked.first       = epochs.time{1}(1,1)*1000; % in ms
mne_evoked.evoked.last        = (mne_evoked.evoked.first/1000+(nsamps-1)/mne_evoked.info.sfreq)*1000; % am ende in ms 

mne_evoked.evoked.times       = linspace(mne_evoked.evoked.first,mne_evoked.evoked.last,nsamps);
mne_evoked.evoked.epochs      = zeros(mne_evoked.info.nchan,nsamps);
mne_evoked.evoked.comment     = conditions{c}; 
mne_evoked.evoked.epochs(MAGIDX,:) = averageMags{c}(:,1:nsamps);
mne_evoked.evoked.epochs(GRDIDX,:) = averageGrads{c}(:,1:nsamps);

fiff_write_evoked([ fpath '/' fname '_' conditions{c} '.fif'],mne_evoked);
clear mne_evoked
end

clear epochs
end
%%
% mne_averaged=fiff_read_evoked_all('test_forward.fif');
% mne_averaged=fiff_read_evoked_all('test_reverse.fif');

