function GenerateHeadModel
% Requires Freesurfer sometimes (for the conversion from aseg.mgz to aseg.nii)
% Requires MNE (for reading the alignment fif during dipole writing)
% Requires the paths to be set correctly

addpath('/scr/kuba2/Dohorap/Main/Data/bat');
addpath('/scr/kuba2/Dohorap/Main/Data/bat/Segmentation');
addpath('/scr/kuba2/Dohorap/Main/Data/bat/Anisotropy');
addpath('/scr/kuba2/Dohorap/Main/Data/bat/Headmodel');
addpath('/scr/kuba1/sw/spm12b/');
addpath('/scr/kuba1/Matlab/nifti');
addpath('/scr/kuba1/Matlab/fieldtrip_120925/external/simbio/');

spm('defaults', 'PET');
spm_jobman('initcfg');
subjects = [1:12 14:16 52:60 62:69];
dipoleCount = 5120;
batchpath = getenv('BATDIR');
for s = subjects
    subject = ['dh' num2str(s,'%02i') 'a'];
    MRIpath = [getenv('MRIDIR') subject '/'];
    modelPath = [getenv('HEADDIR') subject '/'];
    freesurferPath = [getenv('SUBJECTS_DIR') subject '/'];
    megPath = [getenv('EXPDIR') subject '/'];
    if ~exist(modelPath, 'dir'); system(['mkdir ', modelPath]); end;
    cd (MRIpath);
    disp(['Processing subject ' subject]);
    
    % Run the segmentation over the T1 dataset
    if ~exist([MRIpath '/Segmented/c1t1mprsagADNI32Ch.nii'], 'file')
        runSPMscript([batchpath 'Segmentation/segmentMRIdata_job.m']);
    end
    
    % Assemble tissue probability maps into a voxel-based headmodel
    segmentedfile = [MRIpath 'Segmented/segmented_drls_1mm_cfg3.nii'];
    if ~exist(segmentedfile, 'file');
        system([batchpath 'Segmentation/segmentDRLS.sh su']);
    end;
    
    % Extract anisotropy from DWI data
    buildAnisotropy()
    
    % Combine headmodel and anisotropy into mesh (and fix leakage spots)
    tensorfilestem = [MRIpath 'DWI/TensorData/c-'];
    meshfile = [modelPath 'mesh_drls_cfg3.mat'];
    newmeshfile = [meshfile(1:end-4) '-thickened.mat'];
    labelfile = [modelPath 'label.mat'];
    corFile = [freesurferPath 'mri/T1-neuromag/sets/COR-' subject '-aligned.fif'];
    sourceFile = [freesurferPath 'bem/' subject '-ico-5p-src.fif'];
    if exist(segmentedfile, 'file') && exist([tensorfilestem '1.nii'], 'file');
        if ~exist(meshfile, 'file');
            system(['python ' batchpath 'Headmodel/make_mesh.py -s ' segmentedfile ' -c ' tensorfilestem ' -o ' meshfile]);
        end;
        if exist(meshfile, 'file') && ~exist(labelfile, 'file');
            if exist(corFile, 'file');
                correct_cortex_for_Venant([batchpath 'Headmodel/'], sourceFile, labelfile, meshfile, newmeshfile, segmentedfile, corFile);
            else
                disp('Correlation file not found; skipping mesh creation');
            end;
        end;
    end;
    
    % Use Freesurfer sources to place dipoles
    dipoleFile = [modelPath 'distributed_dipoles.dip'];
    if exist(sourceFile, 'file') && exist(corFile, 'file') && ~exist(dipoleFile, 'file')
        writeSimBioDipoles(sourceFile, dipoleFile, dipoleCount, corFile);
    else
        disp('File not found; skipping dipole creation');
    end;
    
    % write out combined vista mesh and conductivity tensor
    vistaFileAniso = [modelPath 'HeadModel-aniso.v'];
	vistaFileIso = [modelPath 'HeadModel-iso.v'];
    if exist(newmeshfile, 'file');
        m = load(newmeshfile); % loads [vert, elem, label, tensors]
        l = load(labelfile); % loads the corrected labels
        if ~exist(vistaFileAniso, 'file');
            write_vista_mesh(vistaFileAniso, double(m.vert), double(m.elem), double(l.labels'), m.tensors);
		  end;
        if ~exist(vistaFileIso, 'file');
            write_vista_mesh(vistaFileIso, double(m.vert), double(m.elem), double(l.labels'));
        end;
    end;
    
    % plot Coregistration between sensors, dipoles and headmodel
    megFile = [megPath subject '1.fif']; 
    if exist(vistaFileIso,'file') && exist(dipoleFile, 'file') && exist(megFile, 'file');
        plotCoregistration(subject, vistaFileIso, dipoleFile, megFile);
    end;
end;
end

function buildAnisotropy
batchpath = '/SCR2/Dohorap/Main/Data/bat/Anisotropy/';
if ~exist('./DWI/DistortionCorrected/ur0066.nii','file');
    disp('Distortion-free files don''t exist yet; regenerating...');
    runSPMscript([batchpath 'DWIMotionCorrection_job.m']);
    % In: DWI/AP, DWI/PA
    % Out: DWI/MovementCorrected (r0001)

    runSPMscript([batchpath 'DWIDistortionCorrection_job.m']);
    % In: DWI/AP, DWI/PA, DWI/MovementCorrected
    % Out: DWI/DistortionCorrected (ur0001)
end

if ~exist('./DWI/DistortionCorrected/rur0066.nii','file');
    disp('Coregistering DWI data to T1 images');
    runSPMscript([batchpath 'CoregisterDWItoT1_job.m']);
    % In: DWI/DistortionCorrected/ur*, T1
    % Out: DWI/DistortionCorrected/rur* with T1 dimensions
end

if ~exist('./DWI/TensorData/EVAL_robust_ru0000-1.nii','file');
    runSPMscript([batchpath 'FitDiffusionTensor_job.m'])
    % In: DWI/DistortionCorrected
    % Out: DWI/TensorData
end

if ~exist('./DWI/TensorData/DiffusionTensor.mat','file');
    CalculateDiffusionTensor;
    % In: DWI/TensorData, Segmented/Brainmask
    % Out: DWI/TensorData/DiffusionTensor.mat
end

if ~exist('./DWI/TensorData/ConductivityTensor.mat','file');
    CalculateAnisotropy;
    % In: DWI/TensorData/DiffusionTensor.mat, Segmented/white- and grey matter masks
    % Out: DWI/TensorData/ConductivityTensor.mat
end
end

function runSPMscript(jobfile)
inputs = cell(0, 1);
spm_jobman('run', jobfile, inputs{:});
end
