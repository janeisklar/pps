function [ ] = split_nifti_4d( nifti4DPath, nifti3DPath, nifti3DName )
%Splits 4D-nifties into single volume 3D-niftis
%   Doesn't do anything on Windows

%% Don't do anything on Windows
if (ispc())
    return
end

%% Check if 3D-nifti files already exist and if their number matches the 4D-nifti's volume count
if ( exist(nifti4DPath, 'file') > 0 )
    
    % Determine the number of 3D-niftis
    [nNiftis, ~] = get_files_using_pattern(nifti3DPath, strcat('^', nifti3DName, '\d*\.nii$'));
    
    % Determine the number of volumes in the 4D-nifti
    nVolumes = get_volume_count_nifti_4d(nifti4DPath);
    
    % Stop processing if the volume amount matches the file count
    if (nNiftis >= nVolumes)
       return
    end
end

%% Split up 4D-niftis into 3D-niftis
[s, r]  = unix(sprintf('FSLOUTPUTTYPE=NIFTI /usr/local/fsl/bin/fslsplit "%s" "%s" -t', nifti4DPath, strcat(nifti3DPath, nifti3DName)));

if (s > 0)
   throw(MException('PPS:FSLError','Failed to split 4D-nifti into single volumes(%s). Output was "%s".', nifti4DPath, r)); 
end

end

