function [ ] = ppProcessMeasurementsScan( scanPath )
%Process specified scan

DS            = filesep();
scanPath      = get_full_path_trailing(scanPath);

%% Use unix command to determine what the scan link is pointing to
test = sprintf('echo "%s" | sed -e "s/\\/*$//" | xargs readlink', scanPath);
[unused, relativeScanPath]  = unix(sprintf('echo "%s" | sed -e "s/\\/*$//" | xargs readlink', scanPath));

realScanPath  = strcat(scanPath, '..', DS, relativeScanPath);
realScanPath  = get_full_path_trailing(realScanPath);

%% Start the processing in the correct scan dir
process_scan(realScanPath);

end