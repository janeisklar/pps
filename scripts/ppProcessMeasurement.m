function [ ] = ppProcessMeasurement( measurementPath )
%All scans in the measurement's folder are being processed

DS               = filesep();
measurementPath  = ppGetFullPathTrailing(measurementPath);

%% Iterate over all scans in the current measurement's folder
scans           = ppGetDirectories(measurementPath);

for k=1:length(scans)
    scan        =scans{k};
    scanPath    = strcat(measurementPath, scan, DS);
    
    ppProcessScan(scanPath);
end

end

