function [ ] = process_all_scans( workingPath )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

DS           = filesep();
workingPath  = get_full_path(workingPath);
subjectsPath = strcat(workingPath, 'subjects', DS);

subjects = get_directories(subjectsPath);

for i=1:length(subjects)
    subject=subjects{i};
    
    subjectPath  = strcat(subjectsPath, subject, DS);
    measurements = get_directories(subjectPath);
    
    for j=1:length(measurements)
        measurement=measurements{j};
        
        measurementPath = strcat(subjectPath, measurement, DS);
        scans           = get_directories(measurementPath);
        
        for k=1:length(scans)
            scan=scans{k};
            
            scanPath    = strcat(measurementPath, scan, DS);
            process_scan(scanPath);
        end
    end
end

end

