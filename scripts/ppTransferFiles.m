function [] = ppTransferFiles( workingDir, transferDir )
% Transfer files and preprocess

%% Import fresh files from the transfer folder
[unused,importFiles] = ppGetFilesUsingPattern(transferDir, '\.ima$');

for i=1:length(importFiles)
    file=importFiles{i};
    ppImportDicom(workingDir,file);
end

%% Convert files and do some basic processing
ppProcessAllScans(workingDir);

end