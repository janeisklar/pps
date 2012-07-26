function [ ] = ppProcessMeasurementsSubject( workingDir, subjectPath )
%All scans in the current subject's folder are being processed

DS           = filesep();
subjectPath  = ppGetFullPathTrailing(subjectPath);

%% Within a subject's folder iterate over all links to scans
scans = ppGetSymlinks(subjectPath);

%% Finally iterate over all scans in the subject folder
for j=1:length(scans)
    scan     = scans{j};    
    scanPath = strcat(subjectPath, scan, DS);
    
    ppProcessMeasurementsScan(workingDir, scanPath);
end

end