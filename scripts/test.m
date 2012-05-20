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
    %% Transfer files and convert them
    [~,importFiles] = get_files_using_pattern(inputDir, '\.ima$');
    
    for file=importFiles
        import_dicom(workingDir,file{1});
    end
    
    
else
    throw(MException('PPS:invalidPath','Source Directory must be either "subject" or "transfer"'));
end