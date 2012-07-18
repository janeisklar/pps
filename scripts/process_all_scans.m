function [ ] = process_all_scans( workingPath )
%All scans in the subject folder are being processed

DS           = filesep();
workingPath  = get_full_path_trailing(workingPath);
subjectsPath = strcat(workingPath, 'subjects', DS);

%% Iterate over all folders in the subjects folder
subjects = get_directories(subjectsPath);

for i=1:length(subjects)
    subject=subjects{i};
    
    %% Process subject
    subjectPath  = strcat(subjectsPath, subject, DS);
    ppProcessSubject(subjectPath);
end

end

