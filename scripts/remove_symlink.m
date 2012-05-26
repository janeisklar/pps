function [ status ] = remove_symlink(link)
%Removes a symlink
%   does nothing on windows
%   returns true if successful

%% Don't do anything on windows
if (ispc())
    status = 0;
    return 
end

%% Create the symlink
[status, unused] = unix(sprintf('unlink "%s"', link));
status           = (status == 0);

end

