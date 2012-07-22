function [ ] = pps( path )
%Runs the pre-processing procedure, that is imports the dicoms and
%preprocesses them. The path can either be the subject
%directory(preprocessing only) or the transfer folder(import and
%preprocessing).

DS          = filesep();

%% Extract path information
exPath      = regexpi(path,'(?<workingDir>.*)(?<mode>subjects|transfer|measurements)(?<subDir>.*)', 'names');
workingDir  = exPath.workingDir;
mode        = exPath.mode;
inputDir    = strcat(workingDir,mode);

% determine nesting level of the subpath by adding the non-empty parts of the path
subDir      = exPath.subDir;
subDirLevel = sum(not(cellfun(@isempty, regexp(subDir, DS, 'split'))));

if (strcmp(mode, 'measurements'))
    %% Preprocessing only
    
    if subDirLevel == 0
      
      % Preprocessing for the whole measurements directory
      ppProcessAllMeasurements(workingDir);
      
    elseif subDirLevel == 1
      
      % Preprocessing for a single measurement date
      ppProcessMeasurementsAtDate(path);
      
    elseif subDirLevel == 2
      
      % Preprocessing for a single subject
      ppProcessMeasurementsSubject(path);
    
    elseif subDirLevel == 3

      % Preprocessing for a single scan
      ppProcessMeasurementsScan(path);
        
    else
      throw(MException('PPS:invalidPath','Source path in the subjects directory can point to either the subjects dir itself, a single subject''s dir, a measurement''s dir or the dir of a single scan. Single DICOMs/Niftis cannot be processed individually!'));
    end
    
elseif (strcmp(mode,'subjects'))
    %% Preprocessing only
    
    if subDirLevel == 0
      
      % Preprocessing for the whole subjects dir
      ppProcessAllScans(workingDir);
      
    elseif subDirLevel == 1
      
      % Preprocessing for a single subject
      ppProcessSubject(path);
      
    elseif subDirLevel == 2
      
      % Preprocessing for a single measurement
      ppProcessMeasurement(path);
      
    elseif subDirLevel == 3
      
      % Preprocessing for a single scan
      ppProcessScan(path);
      
    else
      throw(MException('PPS:invalidPath','Source path in the subjects directory can point to either the subjects dir itself, a single subject''s dir, a measurement''s dir or the dir of a single scan. Single DICOMs/Niftis cannot be processed individually!'));
    end
    
    return
elseif (strcmp(mode,'transfer'))
    %% Transfer files and preprocess
    
    ppTransferFiles(workingDir, inputDir);
else
    throw(MException('PPS:invalidPath','Source Directory must either be a subfolder of the "subject", "measurement" or "transfer" folder!'));
end

end