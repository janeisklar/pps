function [ output_args ] = ppNiftiCheck(path,paraType)

nii=strcat(paraType,'vols.nii');
%vols.nii

%%%DIR%%%
result=dir(nii)
result.name
if result.name ~= nii
    
    %write file: ('missing ', parameters.type, 'vols.nii...processing');
    type=str2func(parameters.type);
    type();
    exisM=exist(parameters.type, 'file');
    
    if exisM == 0
       %write file: ('missing ', paraType, '.m...processing cancelled')
    end
end