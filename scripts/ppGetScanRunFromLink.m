function [ run ] = ppGetScanRunFromLink( link )
% Returns the scan run number for a scan directory that a link is pointing
% at
%   Returns 0 on Windows

%% Don't do anything on Windows
if (ispc())
    run = 0;
    return
end

%% Use unix command to determine what the link is pointing at and extract run number
[unused, r]  = unix(sprintf('readlink "%s" | egrep -o "^scan_([[:digit:]]*)$" | cut -d_ -f 2', link));
run          = str2num(strtrim(r));

end

