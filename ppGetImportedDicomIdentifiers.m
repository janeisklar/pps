function [ hashes, filePaths ] = ppGetImportedDicomIdentifiers(path)

hashes     = {};
filePaths  = {};

%% Iterate over all files in the folder and compute their hash
[unused,files] = ppGetFilesUsingPattern(path, '\.ima$');

for i=1:length(files)
    file             = files{i};
    filePath         = strcat(path, file); 
    hashes{end+1}    = ppGetUniqueDicomIdentifier(filePath);
    filePaths{end+1} = filePath;
end
