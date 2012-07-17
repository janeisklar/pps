function path = get_full_path_trailing(path)
% get_full_path_trailing - Get absolute path
% of a folder with a trailing directory 
% separator

DS                = filesep();
path              = get_full_path(path);
hasTrailingSlash  = sum(strfind(path, DS)==length(path)) > 0;

if ( ~hasTrailingSlash )
  path = strcat(path, DS);
end

end