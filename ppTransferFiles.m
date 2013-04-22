function [] = ppTransferFiles( workingDir, transferDir )
% Transfer files and preprocess

workingDir           = ppGetFullPathTrailing(workingDir);
transferDir          = ppGetFullPathTrailing(transferDir);

%% Check for directories in the transfer dir
dirList              = ppGetDirectories(transferDir);

if length(dirList) > 0
    throw(MException('PPS:InvalidTransferFiles','Directories were found within the transfer folder! This issue needs to be resolved before resuming'));
end

%% Check for invalid files in the tranfer dir
[fileCount,unused]   = ppGetFilesUsingNegativePattern(transferDir, '\.ima$');

if fileCount > 0
    throw(MException('PPS:InvalidTransferFiles','Invalid files were found in the transfer directory that are not DICOM-volumes! This issue needs to be resolved before resuming'));
end

%% Import fresh files from the transfer folder
[unused,importFiles] = ppListTransferFiles(transferDir);

for i=1:length(importFiles)
    file=importFiles{i};
    ppImportDicom(workingDir,transferDir,file);
end

%% Convert files and do some basic processing
%rsl deactivated for bulk import ppProcessAllScans(workingDir);

end
