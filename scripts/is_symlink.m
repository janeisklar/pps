function [ status ] = is_symlink( link )
%Checks if file is a symbolic link
%   returns 1 if symlink or on windows
%   0 otherwise

%% Don't do anything on windows
if (ispc())
    status = 0;
    return 
end

%% Check for symlink
[status, ~] = unix(sprintf('readlink "%s"', link)) == 0;

end

