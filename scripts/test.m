clear all;
clc;

%% DEBUG STUFF *REMOVE*
if (ispc())
    path ='..\\transfer';
else
    path ='../transfer';
end

%% Extract path information
exPath      = regexpi(path,'(?<workingDir>.*)(?<mode>subjects|transfer)', 'names');
workingDir  = exPath.workingDir;
mode        = exPath.mode;
inputDir    = strcat(workingDir,mode);

if (strcmp(mode,'subjects'))
    %% Preprosessing
    
elseif (strcmp(mode,'transfer'))
    %% Transfer files
    [~,importFiles] = get_files_using_pattern(inputDir, '\.ima$');
    
    for i=1:length(importFiles)
        file=importFiles{i};
        import_dicom(workingDir,file);
    end
    
    %% Convert files and do some basic processing
    process_all_scans(workingDir);
else
    throw(MException('PPS:invalidPath','Source Directory must be either "subject" or "transfer"'));
end