function [ ] = ppVerifyScan( workingDir, scanDir )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

DS          = filesep();

dicomDir    = strcat(scanDir,  'dicom', DS);

niftiDir    = strcat(scanDir,  'nifti', DS);
nifti4dPath = strcat(niftiDir, 'vols.nii');

archiveName = 'dicom.tar.gz';
archivePath = strcat(dicomDir, archiveName);

%% Check if 4D-nifti exists
if ( exist(nifti4dPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','4d-nifti missing: "%s".', nifti4dPath)); 
end

%-----------------------------------------------------------------------------------------------------------
    
%% Check if 4D-nifti is valid
% Get number of DICOMs
[nDicoms, unused] = ppGetFilesUsingPattern(dicomDir, '\.ima$');
    
% Determine the number of volumes in the 4D-nifti
nVolumes = ppGetVolumeCountNifti4d(nifti4dPath);
    
if (nVolumes < nDicoms)
    throw(MException('PPS:VerificationError','4d-nifti contains too few volumes: "%s".', nifti4dPath)); 
end

%-----------------------------------------------------------------------------------------------------------

%% Check DICOM archive exists
if ( exist(archivePath, 'file') == 0 )
    throw(MException('PPS:VerificationError','DICOM-archive missing: "%s".', archivePath)); 
end

%-----------------------------------------------------------------------------------------------------------

%% Check if DICOM archive is valid
% Get number of files in the archive
nFiles      = ppGetTarFileCount(archivePath);

% Compare the number of files in the archive with those in the DICOM folder
if ( nFiles < nDicoms )
    throw(MException('PPS:VerificationError','DICOM-archive contains too few DICOMs: "%s".', archivePath));
end

%-----------------------------------------------------------------------------------------------------------

%% Check if statistical derivates exist
meanPath = strcat(niftiDir, 'mean.nii');
stdPath  = strcat(niftiDir, 'std.nii');
snrPath  = strcat(niftiDir, 'snr.nii');

if ( exist(meanPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','Mean volume is missing: "%s".', meanPath)); 
end

if ( exist(stdPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','Standard deviation volume is missing: "%s".', stdPath)); 
end

if ( exist(snrPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','Signal-to-noise volume is missing: "%s".', snrPath)); 
end

%-----------------------------------------------------------------------------------------------------------

%% Check if the data fulfills the requirements of the paradigm
[paradigm, paradigmPath]      = ppFindParadigm(workingDir, scanDir)
[PPmode,dicomVolumes,tarSize] = ppReadParadigm(paradigmPath, paradigm);

ppCheckParadigmDicom(dicomDir,dicomVolumes,tarSize);

%-----------------------------------------------------------------------------------------------------------

%% Check if all requirements to run the preprocessing job were fulfilled
if ( PPmode(1:1) ~= '-' )
    ppCheckParadigmNifti(workingDir, niftiDir, PPmode, 1);
end

%-----------------------------------------------------------------------------------------------------------

end

