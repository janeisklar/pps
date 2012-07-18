function [ returnList ] = get_symlinks( path )
%Returns a list of symlinks in the given path

returnList = {};

dirList    = ls(path);

if (strcmp(dirList, ''))
   return 
end

dirList    = textscan(dirList,'%s','EndOfLine');
dirList    = dirList{1};

%% Keep entries that are directories
for i=1:length(dirList)
    
    dir     = dirList{i};
    dirPath = strcat(path, dir);
    
    if (is_symlink(dirPath))
        returnList{end+1} = dir;
    end
end

end

