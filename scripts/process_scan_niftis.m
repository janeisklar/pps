function process_scan_niftis( scanDir )
%Checks if all the nifti files are present and creates missing files

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
    [nDicoms, ~] = get_files_using_pattern(dicomDir, '\.ima$');
    
    % Determine the number of volumes in the 4D-nifti
    nVolumes = get_volume_count_nifti_4d(nifti4dPath);
    
    if (nVolumes >= nDicoms)
        processing = false;
    end
end


%% If necessary DICOMs are converted into a 4D-nifti
if ( processing )

    [success, error] = convert_dicom_to_nifti(dicomDir, rNifti4dPath);

    if ( ~ success )
       throw(MException('PPS:DICOMConvert','Failed converting DICOMS to nifties. Error message was "%s".', error));
    end

end

% %% Split up 4D-nifti into 3D-nifti files containing a single volume if non-existent
%split_nifti_4d(nifti4dPath, niftiDir, 'vol');

%% Compute some statistical derivates
meanPath = strcat(niftiDir, 'mean.nii');
stdPath  = strcat(niftiDir, 'std.nii');
snrPath  = strcat(niftiDir, 'snr.nii');

create_mean_volume(nifti4dPath, meanPath)
create_std_volume(nifti4dPath,  stdPath)
create_snr_volume(meanPath,     stdPath, snrPath)