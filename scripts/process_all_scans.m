function [ ] = process_all_scans( workingPath )
%All scans in the subject folder are being checked
%and insured that no further processing is required

DS           = filesep();
workingPath  = get_full_path(workingPath);
subjectsPath = strcat(workingPath, 'subjects', DS);

%% Iterate over all folders in the subjects folder
subjects = get_directories(subjectsPath);

for i=1:length(subjects)
    subject=subjects{i};
    
    %% Within a subjects folder iterate over all measurements
    subjectPath  = strcat(subjectsPath, subject, DS);
    measurements = get_directories(subjectPath);
    
    for j=1:length(measurements)
        measurement=measurements{j};
        
        %% Finally iterate over all scans in the current measurements folder
        measurementPath = strcat(subjectPath, measurement, DS);
        scans           = get_directories(measurementPath);
        
        for k=1:length(scans)
            scan=scans{k};
            
            %% Check if processing is necessary
            scanPath    = strcat(measurementPath, scan, DS);
            lockPath    = strcat(scanPath, 'ok.fmri');
            
            %% If processing lock doesn't exist start processing scan
            if ( ~exist(lockPath, 'file') )
                process_scan(scanPath);
            end
            
            %% If we got till here without errors, mark this scan folder as processed
            fid = fopen(lockPath, 'w');
            fwrite(fid, '');
            fclose(fid);
        end
    end
end

end

