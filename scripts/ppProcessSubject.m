function [ ] = ppProcessSubject( workingDir, subjectPath )
%All scans in the current subject's folder are being processed

DS           = filesep();
subjectPath  = ppGetFullPathTrailing(subjectPath);

%% Within a subject's folder iterate over all measurements
measurements = ppGetDirectories(subjectPath);

for j=1:length(measurements)
    measurement=measurements{j};
    
    %% Finally iterate over all scans in the current measurements folder
    measurementPath = strcat(subjectPath, measurement, DS);
    ppProcessMeasurement(workingDir, measurementPath);
end

end

