
addpath('/scr/kuba2/sw/spm12b/');
spm('defaults', 'PET');
spm_jobman('initcfg');
% subjects = ['15,'16']';
%for subject = subjects
subject = '71'
    fullpath = ['/scr/kuba2/Dohorap/Main/Data/MRI/dh', subject, 'a'];
    cd(fullpath);
    jobfile = {'/scr/kuba2/Dohorap/Main/Data/bat/Freesurfer/coregisterT1toT2_job.m'};
    jobs = repmat(jobfile, 1, 1);
    inputs = cell(0, 1);
    spm_jobman('run', jobs, inputs{:});
%end;
