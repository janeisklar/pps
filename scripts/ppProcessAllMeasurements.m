function [ ] = ppProcessAllMeasurements( workingPath )
%All scans in the measurements folder are being processed

DS               = filesep();
workingPath      = get_full_path_trailing(workingPath);
measurementsPath = strcat(workingPath, 'measurements', DS);

%% Iterate over all folders in the measurements folder
dates = get_directories(measurementsPath);

for i=1:length(dates)
    date=dates{i};
    
    %% Process subject
    measurementPath = strcat(measurementsPath, date, DS);
    ppProcessMeasurementsAtDate(measurementPath);
end

end

