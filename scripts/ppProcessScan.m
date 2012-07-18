function [ ] = ppProcessScan( scanDir )
%Process a directory of a scan
%   handles nifti-conversion and DICOM-archiving

scanDir = ppGetFullPathTrailing(scanDir);
success = true;

try
    %% Check if processing is necessary
    lockPath    = strcat(scanDir, 'ok.fmri');
    
    %% If processing lock doesn't exist start processing scan
    if ( exist(lockPath, 'file') )
      return;
    end
  
  
    %% Check presence of niftis
    success = ppProcessScanNiftis(scanDir);
    
    if ( ~success )
        return;
    end

    %% Check presence of DICOM tar archive
    ppProcessScanArchive(scanDir);

    if ( ~success )
        return;
    end
    
    %% Do the actual preprocessing
    ppParadigm(scanDir)
    
    %% Validate the processing steps
    ppVerifyScan(scanDir);

catch e
    
    %% In case of an error write error message to the designated error file
    errorPath   = strcat(scanDir, 'error.fmri');
    fid         = fopen(errorPath, 'w');
    fwrite(fid, e.message);
    fclose(fid);
    
    success     = false;
end

%% If we got till here without errors, mark this scan as processed
if success
    lockPath    = strcat(scanDir, 'ok.fmri');
    fid         = fopen(lockPath, 'w');
    fwrite(fid, '');
    fclose(fid);
end

end