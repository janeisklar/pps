function [ ] = ppProcessMeasurementsAtDate( datePath )
%All scans in the measurements sub-folder for a specific are being processed

DS        = filesep();
datePath  = get_full_path_trailing(datePath);

%% Iterate over all folders in the measurement date's folder
subjects  = get_directories(datePath);

for i=1:length(subjects)
    subject=subjects{i};
    
    %% Process subject
    subjectPath  = strcat(datePath, subject, DS);
    ppProcessMeasurementsSubject(subjectPath);
end

end

