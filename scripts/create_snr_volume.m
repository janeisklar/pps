function [ ] = create_snr_volume( meanPath, stdPath, snrPath )
%Creates a single-to-noise nifti from the mean and std volume

%% Check if snr already exists and is recent
if ( exist(snrPath, 'file') > 0 )
    
    snr  = dir(snrPath);
    std  = dir(stdPath);
    mean = dir(meanPath);
    
    % Stop processing if mean and std not newer than snr
    if (snr.datenum >= std.datenum && snr.datenum >= mean.datenum)
        return
    end
end

%% Create snr volume
[s, r]  = unix(sprintf('FSLOUTPUTTYPE=NIFTI /usr/local/fsl/bin/fslmaths "%s" -div "%s" "%s"', meanPath, stdPath, snrPath));

if (s > 0)
   throw(MException('PPS:FSLError','Failed to create snr volume from mean and std nifti file(%s, %s). Output was "%s".', meanPath, stdPath, r)); 
end

end

