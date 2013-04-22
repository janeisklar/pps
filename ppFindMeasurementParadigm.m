function [ paradigmPath ] = ppFindMeasurementParadigm(workingDir, measurementPath)
% Finds the corresponding paradigm.txt for a measurement directory

DS           = filesep();
scans        = ppGetDirectories(measurementPath);
paradigmPath = '';

for k=1:length(scans)
    scan     = scans{k};
    scanPath = strcat(measurementPath, scan, DS);

    try
    	[unused,paradigmPath]=ppFindParadigm(workingDir, scanPath);
    catch e
        % if unsuccessful try the next scan
	continue
    end

    % if we get till here we've found the paradigm.txt
    return
end

end
