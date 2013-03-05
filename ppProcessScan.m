function [ ] = ppProcessScan( workingDir, scanDir )
%Process a directory of a scan
%   handles nifti-conversion and DICOM-archiving

scanDir     = ppGetFullPathTrailing(scanDir);
errorPath   = strcat(scanDir, 'ERROR.fmri');
success     = true;

try
    %% Check if processing is necessary
    lockPath    = strcat(scanDir, 'OKAY.fmri');
    

    %% If processing lock doesn't exist start processing scan
    if ( exist(lockPath, 'file') )
      return;
    end
    
    % If error file exists remove it prior processing so that only recent errors are stored
    if ( exist(errorPath, 'file') )
      delete(errorPath);
    end
    
    % Check if scan is in paradigm list
    [ paradigm, paradigmPath ] = ppFindParadigm(workingDir, scanDir);
    ppReadParadigm(paradigmPath,paradigm);
    
    %% Check presence of niftis
    success = ppCreateNiftis(scanDir);
    
    if ( ~success )
        return;
    end

    %% Check presence of DICOM tar archive
    ppCreateDicomBackup(scanDir);

    if ( ~success )
        return;
    end
    
    %% Do the actual preprocessing
    ppRunPreprocessingJob(workingDir, scanDir);
    
    %% Validate the processing steps
    ppVerifyScan(workingDir, scanDir);

catch e
    if isempty(strfind(e.message, 'couldnt find Paradigm in .txt')) %rsl 12-10-04 ignore this warning

        %% In case of an error write error message to the designated error file
        fid         = fopen(errorPath, 'w');
        fwrite(fid, sprintf('%s(%s:%d)\n', e.message, e.stack(1).name, e.stack(1).line));
        fclose(fid);
    
        success     = false;
    end
end

%% If we got till here without errors, mark this scan as processed
if success
    lockPath    = strcat(scanDir, 'OKAY.fmri');
    fid         = fopen(lockPath, 'w');
    fwrite(fid, '');
    fclose(fid);
end

%% Either way, update findings.fmri to represent the new error count
unix(sprintf('echo `find %s../ -name ERROR.fmri -print |wc -l`" Errors, 0 Warnings" > %s../FINDINGS.fmri', scanDir, scanDir)); 

end
