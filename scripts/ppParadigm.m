function [ output_args ] = 	ppParadigm(workingDir, scanDir)
% searches for (specific) paradigm.txt

DS                = filesep();
dicomDir          = strcat(scanDir,DS,'dicom',DS);
niftiDir          = strcat(scanDir,DS,'nifti',DS);

[volumes,files]   = ppGetFilesUsingPattern(dicomDir, '\.ima$');

%% Error in case folder does not contain a DICOM file
if ( volumes < 1 )
    throw(MException('PPS:DICOMCheck','Failed to read information, DICOMs are missing'));
    return
end

filePath          = strcat(dicomDir,files{1});
[info,header]     = ppFileinfo(filePath);

measurement       = header.PatientName.GivenName;
paradigm          = header.ProtocolName;

%% Error in case DICOM header is empty
if ( isempty(measurement) || isempty(paradigm) )
    throw(MException('PPS:DICOMCheck','Failed to read DICOM header, data is missing'));
end

%% Search for the right paradigm(_xxx).txt
specParadigm      = strcat('paradigms_', measurement, '.txt');
specParadigmPath  = strcat(workingDir, 'jobs', DS, specParadigm);
paradigmPath      = strcat(workingDir, 'jobs', DS, 'paradigms.txt');

if ( exist(specParadigmPath) > 0 )
    paradigmPath  = specParadigmPath;
end

if ( exist(paradigmPath) < 1 )
    throw(MException('PPS:DICOMCheck','Failed to read paradigm, paradigms.txt is missing'));
    return
end

%% Read out the information contained in the paradigms.txt
[PPmode,dicomVolumes,tarSize] = ppReadParadigm(paradigmPath,paradigm);

%% Check if the data fulfills the requirements of the paradigm
if ( ppDicomCheck(dicomDir,dicomVolumes,tarSize) == 0 )
    return
end

%% Error if no preprocessing mode is specified in paradigm.txt
if ( length(PPmode) < 1 )
    throw(MException('PPS:DICOMCheck','Failed to read paradigm, mode is missing in paradigm.txt'));
    return
end

%% Skip preprocessing when paradigm is set to '-'
if ( PPmode(1:1) == '-' )
    return
end

%% Check if all requirements to run the preprocessing job are fulfilled
if ( ppNiftiCheck(workingDir, niftiDir, PPmode) == 0 )
    return
end

%% Prepare the inputs for the job
niftiFilePath   = strcat(niftiDir,'vols.nii');
nSlices         = ppGetVolumeCountNifti4d(niftiFilePath);

job             = strcat(PPmode,'_job.m');
jobFilePath     = strcat(workingDir, 'jobs', DS, job);

jobFile         = {jobFilePath};
jobs            = repmat(jobFile, 1, 1);

inputs          = cell(1,1);
slices          = {};

for s = 1:nSlices
    slices{s}   = sprintf('%s,%d', niftiFilePath, s);
end

inputs{1,1} = slices';

%% Run the actual job file
spm('defaults', 'FMRI');
spm_jobman('initcfg');
spm_jobman('serial', jobs, '', inputs{:});