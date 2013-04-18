function [ paradigmPath ] = ppUpdateFindingsLog(measurementPath)
%% Updates findings.fmri to represent the new error count

measurementPath  = ppGetFullPathTrailing(measurementPath);

unix(sprintf('echo `find %s -name ERROR.fmri -print |wc -l`" Errors, 0 Warnings" > %sFINDINGS.fmri', measurementPath, measurementPath));

end
