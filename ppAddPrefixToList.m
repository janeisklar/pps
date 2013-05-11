function [ prefixedFiles ] = ppAddPrefixToList(files, prefix)
%% Takes in a list of paths like:
% {'subjects/ket-027/m1/scan_0025/nifti/vols.nii,1', ..}
% and adds a prefix to the file name to give:
% {'subjects/ket-027/m1/scan_0025/nifti/wuavols.nii,1', ..}
    prefixedFiles = cell(length(files),1);
    for i=1:length(files)
        file = files{i};
        prefixedFiles{i,1} = fliplr(regexprep(fliplr(file), '^([^/]*)/(.*)$', ['$1' fliplr(prefix) '/$2']));
    end
end