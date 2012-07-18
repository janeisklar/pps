function [ count ] = ppGetTarFileCount( tarPath )
% Returns the number of files in a tar file
%   Returns 99999 on Windows

%% Don't do anything on Windows
if (ispc())
    count = 99999;
    return
end

%% Use the shell tar utility to list the files in the archive and count them
[unused, r]  = unix(sprintf('tar tf "%s" | grep -i .ima | wc -l', tarPath));
count        = str2num(strtrim(r));

end

