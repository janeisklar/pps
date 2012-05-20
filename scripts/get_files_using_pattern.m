function [ count, returnList ] = get_files_using_pattern( path, pattern )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

fileList   = ls(path);
fileList   = textscan(fileList,'%s','EndOfLine');
fileList   = fileList{1};

returnList = {};

%% Keep files matching pattern
for i=1:length(fileList)
    file = fileList{i};

    if (regexpi(file, pattern))
        returnList{end+1} = file;
    end
end

count = length(returnList);

end

