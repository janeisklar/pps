function [ status ] = ppCreateMeanVolume( nifti4dPath, meanPath )
%Creates a mean nifti from all volumes in the scan

status = 0;

%% Check if mean already exists and is recent
if ( exist(meanPath, 'file') > 0 )
    
    mean  = dir(meanPath);
    nifti = dir(nifti4dPath);
    
    % Stop processing if volume newer than mean
    if (mean.datenum < nifti.datenum)
        throw(MException('PPS:FSLError','4D-nifti file(%s) is newer than it''s mean volume(%s): %s > %s. Resolve before processing can be continued.', nifti4dPath, meanPath, nifti.date, mean.date));
    end
    
    return;
end

%% Create mean volume
[s, r]  = unix(sprintf('FSLOUTPUTTYPE=NIFTI /usr/local/fsl/bin/fslmaths "%s" -Tmean "%s"', nifti4dPath, meanPath));
status  = s==0;

if (s > 0)
   throw(MException('PPS:FSLError','Failed to create mean volume from a 4D-nifti file(%s). Output was "%s".', nifti4dPath, r)); 
end

end

