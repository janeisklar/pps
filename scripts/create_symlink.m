function [ status ] = create_symlink(source, target)
%Creates a symlink from target to source
%   does nothing on windows
%   returns true if successful

%% Don't do anything on windows
if (ispc())
    status = 0;
    return 
end

%% Create the symlink
[status, unused] = unix(sprintf('ln -s "%s" "%s"', source, target));
status           = (status == 0);

end

