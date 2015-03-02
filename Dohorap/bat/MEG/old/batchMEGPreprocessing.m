clear;

workstation = 1; % 1: kuba, 2: Laptop; 3: Aachen
suffix.base = 'mc';
suffix.ica = 'ICA-corrected';
suffix.filter = 'hp004';
suffix.goal = 'onset'; % onset / feedback / decision
recreate.highpass = 0;
recreate.rejection = 0;
recreate.averageData = 1;
recreate.fifFiles = 1;
do.save = 1;
do.print = 0;
do.rejectLowPerformers = 1;
subjects = {2:19, 52:71};

switch workstation;
    case 1; paths.data = '/scr/kuba2'; projectPath = '/scr/kuba2/Dohorap/Main/Data'; 
    case 2; paths.data = '/Volumes/Untitled/SCR'; projectPath = '/Users/goocy/Documents/Dohorap';
    case 3; paths.data = '/media/sdd1'; projectPath = '/home/data/hanrath/Dohorap/';
end;
paths.MEG = [paths.data '/Dohorap/Main/Data/MEG/motionCorrected'];
paths.presentation = [paths.data '/Dohorap/Main/Data/Presentation'];
setenv('DOCDIR',[projectPath '/doc']);
addpath([projectPath '/bat']);
addpath([projectPath '/bat/MEG']);

for group = 1:2
    for subjectID = subjects{group}
        subject = ['/dh' num2str(subjectID, '%02i') 'a'];
        if recreate.highpass
            for block = [1,2]
                eogFile = [paths.MEG subject subject num2str(block) '_' suffix.base '.fif'];
                hpFile = [paths.MEG subject subject num2str(block) '_' suffix.base '_' suffix.filter '_' suffix.ica '.fif'];
                if exist(eogFile, 'file') && ~exist(hpFile, 'file')
                    MEGhighpass(paths, suffix.base, eogFile, hpFile);
                end;
            end;
        end;
        MEG_Preprocessing(subject, suffix, recreate, paths, do);
    end;
end