function [ output_args ] = 	ppRunPreprocessingJob(workingDir, scanDir)
% searches for the (specific) paradigm.txt, extracts paradigm information 
% and executes the corresponding SPM preprocessing job.

DS                = filesep();
dicomDir          = strcat(scanDir,DS,'dicom',DS);
niftiDir          = strcat(scanDir,DS,'nifti',DS);

[paradigm, paradigmPath] = ppFindParadigm(workingDir, scanDir);

%% Read out the information contained in the paradigms.txt
[PPmode,dicomVolumes,tarSize] = ppReadParadigm(paradigmPath,paradigm);

%% Check if the data fulfills the requirements of the paradigm
if ( ppCheckParadigmDicom(dicomDir,dicomVolumes,tarSize) == 0 )
    return
end

%% Skip preprocessing when paradigm is set to '-'
if ( PPmode(1:1) == '-' )
    return
end

%% Check if all requirements to run the preprocessing job are fulfilled
if ( ppCheckParadigmNifti(workingDir, niftiDir, PPmode, 0) == 0 )
    return
end

%% Prepare the inputs for the job
niftiFilePath   = strcat(niftiDir,'vols.nii');
nVolumes        = ppGetVolumeCountNifti4d(niftiFilePath);

job             = strcat(PPmode,'_job');
jobFilePath     = strcat(workingDir, 'jobs', DS, job);

jobFile         = {jobFilePath};
jobs            = repmat(jobFile, 1, 1);

inputs          = cell(1,1);
volumes         = {};

for s = 1:nVolumes
    volumes{s}  = sprintf('%s,%d', niftiFilePath, s);
end

inputs{1,1} = volumes';

%% Run the actual job file
spm('defaults', 'FMRI');
spm_jobman('initcfg');
%spm_jobman('serial', jobs, '', inputs{:});
cd( [ workingDir 'jobs' ] );
matlabbatch = {};
job
eval( job );
spm_jobman('run', matlabbatch);
