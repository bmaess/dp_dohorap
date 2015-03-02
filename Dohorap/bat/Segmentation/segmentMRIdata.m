% List of open inputs
addpath('/scr/kuba1/sw/spm12b');
mridir = getenv('MRIDIR');
spm_jobman('initcfg');
for subject = [52:60 62:69];
    s = ['dh' num2str(subject) 'a'];
    subjectpath = [mridir s];
    cd (subjectpath);
    jobfile = {'/SCR2/Dohorap/Main/Data/bat/Segmentation/segmentMRIdata_job.m'};
    jobs = repmat(jobfile, 1, 1);
    inputs = cell(0, 1);
    spm('defaults', 'PET');
    spm_jobman('run', jobs, inputs{:});
end;
