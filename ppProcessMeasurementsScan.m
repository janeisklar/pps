function [ ] = ppProcessMeasurementsScan( workingDir, scanPath )
%Process specified scan

DS            = filesep();
scanPath      = ppGetFullPathTrailing(scanPath);

%% Use unix command to determine what the scan link is pointing to
test = sprintf('echo "%s" | sed -e "s/\\/*$//" | xargs readlink', scanPath);
[unused, relativeScanPath]  = unix(sprintf('echo "%s" | sed -e "s/\\/*$//" | xargs readlink', scanPath));

realScanPath  = strcat(scanPath, '..', DS, relativeScanPath);
realScanPath  = ppGetFullPathTrailing(realScanPath);

%% Start the processing in the correct scan dir
ppProcessScan(workingDir, realScanPath);

end
