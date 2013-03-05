function [ ] = ppProcessAllScans( workingDir )
%All scans in the subject folder are being processed

DS           = filesep();
workingDir   = ppGetFullPathTrailing(workingDir);
subjectsPath = strcat(workingDir, 'subjects', DS);

%% Iterate over all folders in the subjects folder
subjects = ppGetDirectories(subjectsPath);

for i=1:length(subjects)
    subject=subjects{i};
    
    %% Process subject
    subjectPath  = strcat(subjectsPath, subject, DS);
    ppProcessSubject(workingDir, subjectPath);
end

end

