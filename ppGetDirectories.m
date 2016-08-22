function [ returnList ] = ppGetDirectories( path )
%Returns a list of directories in the given path

returnList = {};

dirList    = ls(path);

if (strcmp(dirList, ''))
   return 
end

dirList    = textscan(dirList,'%s');
dirList    = dirList{1};

%% Keep entries that are directories
for i=1:length(dirList)
    
    dir     = dirList{i};
    dirPath = strcat(path, dir);
    
    if (isdir(dirPath) && ~ppIsSymlink(dirPath))
        returnList{end+1} = dir;
    end
end

end

