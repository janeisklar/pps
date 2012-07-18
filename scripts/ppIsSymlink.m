function [ status ] = ppIsSymlink( link )
%Checks if file is a symbolic link
%   returns 1 if symlink or on windows
%   0 otherwise

%% Don't do anything on windows
if (ispc())
    status = 0;
    return 
end

%% Check for symlink
[status, unused] = unix(sprintf('readlink "%s"', link));
status           = (status == 0);

end