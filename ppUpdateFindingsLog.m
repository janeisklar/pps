function [] = ppUpdateFindingsLog(measurementPath)
%% Updates findings.fmri to represent the new error count

measurementPath = ppGetFullPathTrailing(measurementPath);
findingsLogPath = strcat(measurementPath, 'FINDINGS.fmri');

[unused,nErrors]= unix(sprintf('find %s -name "ERROR.fmri" | wc -l', measurementPath));
nErrors         = str2num(nErrors);

if nErrors > 0
    unix(sprintf('echo "%d Errors, 0 Warnings" > %s', nErrors, findingsLogPath));
else
    if ( exist(findingsLogPath, 'file') )
      delete(findingsLogPath);
    end
end

end
