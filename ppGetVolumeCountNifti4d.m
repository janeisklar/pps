function [ nSlices ] = ppGetVolumeCountNifti4d( niftiPath )
%Returns the number of volumes that are contained in a single 4D-nifti file
%   0 on Windows

if (ispc())
    nSlices = 0;
    return
end

[s, r]  = unix(sprintf('FSLOUTPUTTYPE=NIFTI /usr/local/fsl/bin/fslnvols "%s"', niftiPath));
nSlices = str2num(strtrim(r));

if (s > 0)
   throw(MException('PPS:FSLError','Failed to retrieve volume count from a 4D-nifti file(%s). Output was "%s".', niftiPath, r)); 
end


end

