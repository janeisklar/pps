function [ ] = ppProcessMeasurementsAtDate( workingDir, datePath )
%All scans in the measurements sub-folder for a specific are being processed

DS        = filesep();
datePath  = ppGetFullPathTrailing(datePath);

%% Iterate over all folders in the measurement date's folder
%% Within a date's folder iterate over all links to subjects
subjects = ppGetSymlinks(datePath);

for i=1:length(subjects)
    subject=subjects{i};
    
    %% Process subject
    subjectPath  = strcat(datePath, subject, DS);
    ppProcessMeasurementsSubject(workingDir, subjectPath);
end

end

