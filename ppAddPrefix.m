function [ prefixedFile ] = ppAddPrefix(file, prefix)
%% Takes in a path like:
% 'subjects/ket-027/m1/scan_0025/nifti/vols.nii,33'
% adds a prefix to the file name and strips the volume number to form
%'subjects/ket-027/m1/scan_0025/nifti/wuavols.nii'
    prefixedFile = fliplr(regexprep(fliplr(file), '^[^,]*,?([^/]*)/(.*)$', ['$1' fliplr(prefix) '/$2']));
end