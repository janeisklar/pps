function path = ppGetFullPathTrailing(path)
% ppGetFullPathTrailing - Get absolute path
% of a folder with a trailing directory 
% separator

DS                = filesep();
path              = ppGetFullPath(path);
hasTrailingSlash  = sum(strfind(path, DS)==length(path)) > 0;

if ( ~hasTrailingSlash )
  path = strcat(path, DS);
end

end
