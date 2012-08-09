function [ ] = ppProcessMeasurementsScan( workingDir, scanPath )
%Process specified scan

DS            = filesep();
scanPath      = ppGetFullPathTrailing(scanPath);

%% Use unix command to resolve any symbolic links in the path
[unused, realScanPath]  = unix(sprintf('cd "%s" && pwd -P', scanPath));
realScanPath            = strcat(realScanPath, DS);

%% Start the processing in the correct scan dir
ppProcessScan(workingDir, realScanPath);

end