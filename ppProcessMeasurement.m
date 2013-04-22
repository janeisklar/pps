function [ ] = ppProcessMeasurement( workingDir, measurementPath )
%All scans in the measurement's folder are being processed

DS               = filesep();
measurementPath  = ppGetFullPathTrailing(measurementPath);
paradigmSpecPath = ppFindMeasurementParadigm(workingDir, measurementPath);
errorFilePath    = strcat(measurementPath, 'ERROR.fmri');

% If error file exists remove it prior processing so that only recent errors are stored
if ( exist(errorFilePath, 'file') )
   delete(errorFilePath);
end

if length(paradigmSpecPath)  < 1
    %% In case of an error write error message to the designated error file
    errorFilePath = errorFilePath
    fid = fopen(errorFilePath, 'w');
    fwrite(fid, sprintf('Paradigms(_$measurement$).txt could not be found for %s\n', measurementPath));
    fwrite(fid, sprintf('\n--------------------------------------------------\n'));
    fclose(fid);
    return
end

paradigms        = ppListParadigms(paradigmSpecPath);

%% Iterate over all paradigms in the current measurement's folder

for k=1:length(paradigms)

    try
    	paradigm     = paradigms{k};
	paradigmPath = strcat(measurementPath, paradigm.paradigm)
	scanRun      = ppGetScanRunFromLink(paradigmPath);

        if isempty(scanRun)
       	    throw(MException('PPS:MeasurementProcessingError','Paradigm "%s" is missing for "%s".', paradigm.paradigm, measurementPath));
        end

	scan         = sprintf('scan_%04d', scanRun);
        scanPath     = strcat(measurementPath, scan, DS)

        ppProcessScan(workingDir, scanPath);
    catch e
        %% In case of an error write error message to the designated error file
    	errorFilePath = errorFilePath
	fid = fopen(errorFilePath, 'w');
        fwrite(fid, sprintf('%s(%s:%d)\n', e.message, e.stack(1).name, e.stack(1).line));
        fwrite(fid, sprintf('\n--------------------------------------------------\n'));
    	fclose(fid);
    end
end

%% Either way, update findings.fmri to represent the new error count
ppUpdateFindingsLog(measurementPath);

end
