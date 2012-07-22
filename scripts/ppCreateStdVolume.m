function [ status ] = ppCreateStdVolume( nifti4dPath, stdPath )
%Creates a std nifti from all volumes in the scan

status = 0;

%% Check if std already exists and is recent
if ( exist(stdPath, 'file') > 0 )
    
    std  = dir(stdPath);
    nifti = dir(nifti4dPath);
    
    % Stop processing if volume not newer than std
    if (std.datenum < nifti.datenum)
        throw(MException('PPS:FSLError','4D-nifti file(%s) is newer than it''s std. deviation volume(%s): %s > %s. Resolve before processing can be continued.', nifti4dPath, stdPath, nifti.date, std.date));
    end
    
    return
end

%% Create std volume
[s, r]  = unix(sprintf('FSLOUTPUTTYPE=NIFTI /usr/local/fsl/bin/fslmaths "%s" -Tstd "%s"', nifti4dPath, stdPath));
status  = s==0;

if (s > 0)
   throw(MException('PPS:FSLError','Failed to create std volume from a 4D-nifti file(%s). Output was "%s".', nifti4dPath, r)); 
end

end