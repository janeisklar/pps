function [ ] = pps( path )
%Runs the pre-processing procedure, that is imports the dicoms and
%preprocesses them. The path can either be the subject
%directory(preprocessing only) or the transfer folder(import and
%preprocessing).

%% Extract path information
exPath      = regexpi(path,'(?<workingDir>.*)(?<mode>subjects|transfer)', 'names');
workingDir  = exPath.workingDir;
mode        = exPath.mode;
inputDir    = strcat(workingDir,mode);

if (strcmp(mode,'subjects'))
    %% Preprosessing
    
elseif (strcmp(mode,'transfer'))
    %% Transfer files
    [unused,importFiles] = get_files_using_pattern(inputDir, '\.ima$');
    
    for i=1:length(importFiles)
        file=importFiles{i};
        import_dicom(workingDir,file);
    end
    
    %% Convert files and do some basic processing
    process_all_scans(workingDir);
else
    throw(MException('PPS:invalidPath','Source Directory must be either "subject" or "transfer"'));
end

end