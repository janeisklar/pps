function [ ] = ppProcessMeasurement( measurementPath )
%All scans in the measurement's folder are being 
%checked and insured that no further processing is
%required

DS               = filesep();
measurementPath  = get_full_path_trailing(measurementPath);

%% Iterate over all scans in the current measurement's folder
scans           = get_directories(measurementPath);

for k=1:length(scans)
    scan        =scans{k};
    scanPath    = strcat(measurementPath, scan, DS);
    
    process_scan(scanPath);
end

end

