function [ output_args ] = import_dicom(workingDir,fileName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fprintf('processing %s \n', fileName )

filePath=strcat(workingDir,'transfer','/',fileName);
[info,header] = fileinfo(filePath);
info
end

