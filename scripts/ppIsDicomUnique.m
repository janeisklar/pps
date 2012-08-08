function [ isUnique, conflictingFile ] = ppIsDicomUnique(needlePath, haystackPath)
% Checks if the needle(new dicom file) can be found in the haystack(existing dicom files)
% while relying only on the header information and ignoring the file name. 
% If it can't be found the dicom can be considered unique.

isUnique               = 0;
conflictingFile        = '';

%% Get the needle's unique identifier
needleId               = ppGetUniqueDicomIdentifier(needlePath);

%% Iterate over all haystack files and compare to the needle
[unused,haystackFiles] = ppGetFilesUsingPattern(haystackPath, '\.ima$');

for i=1:length(haystackFiles)
    haystackFile       = haystackFiles{i};
    haystackFilePath   = strcat(haystackPath, haystackFile);
    haystackId         = ppGetUniqueDicomIdentifier(haystackFilePath);
    
    % Break if the needle's identifier is present in the haystack
    if ( strcmp(haystackId, needleId) == 1 )
        isUnique       = 0;
        conflictingFile= haystackFilePath;
        return;
    end
end

isUnique = 1; 