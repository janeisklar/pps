function [ ] = ppProcessMeasurementsSubject( workingDir, subjectPath )
%All scans in the current subject's folder are being processed

DS           = filesep();
subjectPath  = ppGetFullPathTrailing(subjectPath)

%% Use unix command to determine what the subject link is pointing to
[unused, relativeSubjectPath]  = unix(sprintf('cd "%s" && pwd -P', subjectPath));
relativeSubjectPath            = strcat(relativeSubjectPath, DS);

%% Within a subject's folder iterate over all links to scans
scans = ppGetDirectories(relativeSubjectPath);

%% Finally iterate over all scans in the subject folder
for j=1:length(scans)
    scan     = scans{j};    
    scanPath = strcat(subjectPath, scan, DS);
    
    ppProcessScan(workingDir, scanPath);
end

end