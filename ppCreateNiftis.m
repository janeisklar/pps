function [ success ] = ppCreateNiftis( scanDir )
%Checks if all the nifti files are present and creates missing files

success     = true;
DS          = filesep();

dicomDir    = strcat(scanDir,  'dicom', DS);

rNiftiDir   = strcat('..', DS, 'nifti', DS);
rNifti4dPath= strcat(rNiftiDir,'vols.nii');

niftiDir    = strcat(scanDir,  'nifti', DS);
nifti4dPath = strcat(niftiDir, 'vols.nii');

%% Check if nifti conversion is necessary
processing  = true;
if ( exist(nifti4dPath, 'file') > 0 )
    
    % Get number of DICOMs
    [nDicoms, unused] = ppGetFilesUsingPattern(dicomDir, '\.ima$');
    
    % Determine the number of volumes in the 4D-nifti
    nVolumes = ppGetVolumeCountNifti4d(nifti4dPath);
    
    if (nVolumes >= nDicoms)
        processing = false;
    end
end


%% If necessary DICOMs are converted into a 4D-nifti
if ( processing )

    [success, error] = ppConvertDicomToNifti(dicomDir, rNifti4dPath);

    if ( ~success )
       throw(MException('PPS:DICOMConvert','Failed converting DICOMS to nifties. Error message was "%s".', error));
       return
    end
end

if ( ~success )
    return;
end

% %% Split up 4D-nifti into 3D-nifti files containing a single volume if non-existent
%ppSplitNifti4d(nifti4dPath, niftiDir, 'vol');

%% Compute some statistical derivates
meanPath = strcat(niftiDir, 'mean.nii');
stdPath  = strcat(niftiDir, 'std.nii');
snrPath  = strcat(niftiDir, 'snr.nii');

if ( exist(meanPath, 'file') < 1 )
    success  = success && ppCreateMeanVolume(nifti4dPath, meanPath);
end

if ( exist(stdPath, 'file') < 1 )
    success  = success && ppCreateStdVolume(nifti4dPath, stdPath);
end

if ( exist(snrPath, 'file') < 1 )
    success  = success && ppCreateSnrVolume(meanPath, stdPath, snrPath);
end

end