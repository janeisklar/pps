function [ count, returnList ] = ppGetFilesUsingNegativePattern( path, pattern )
%Returns the list of files of the given directory after filtering them
%using a regular expression


count      = 0;
returnList = {};

fileList   = ls(path);

if (strcmp(fileList, ''))
   return 
end

fileList   = textscan(fileList,'%s','EndOfLine');
fileList   = fileList{1};

%% Keep files matching pattern
for i=1:length(fileList)
    file = fileList{i};

    if (regexpi(file, pattern))
      % ignore
    else
      returnList{end+1} = file;
    end
end

count = length(returnList);

end
