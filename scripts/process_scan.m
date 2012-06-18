function [ ] = process_scan( scanDir )
%Process a directory of a scan
%   handles nifti-conversion and DICOM-archiving

success = true;

try

    %% Check presence of niftis
    success = process_scan_niftis(scanDir);
    
    if ( ~success )
        return;
    end

    %% Check presence of DICOM tar archive
    process_scan_archive(scanDir);

    if ( ~success )
        return;
    end
    
    %% Do the actual preprocessing
    ppParadigm(scanDir)
    
    %% Validate the processing steps
    pps_verify_scan(scanDir);

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