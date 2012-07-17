function [ ] = ppProcessSubject( subjectPath )
%All scans in the current subject's folder are being
%checked and insured that no further processing is 
%required

DS           = filesep();
subjectPath  = get_full_path_trailing(subjectPath);

%% Within a subject's folder iterate over all measurements
measurements = get_directories(subjectPath);

for j=1:length(measurements)
    measurement=measurements{j};
    
    %% Finally iterate over all scans in the current measurements folder
    measurementPath = strcat(subjectPath, measurement, DS);
    ppProcessMeasurement(measurementPath);
end

end

