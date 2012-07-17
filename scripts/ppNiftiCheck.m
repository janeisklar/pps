function [ output_args ] = ppNiftiCheck(path,PPmode)
%checks the existance and completeness of NIfTI files


nii=strcat(path,'vols.nii');
modeNii=strcat(path,PPmode,'vols.nii');

niiPara=dir(nii);
modeNiiPara=dir(modeNii);


% returns an error in case vols.nii does not exist or is empty
if exist(nii) == 0 || niiPara.bytes == 0
    
    throw(MException('PPS:NIfTICheck','vols.nii is missing or is empty');
   
end

% returns an error in case vols.nii of preprocessing does not exist or is empty
if exist(modeNii) == 0 || modeNiiPara.bytes == 0
    
    throw(MException('PPS:NIfTICheck',PPmode,'vols.nii is missing or is empty. Preprocessing in progress');
    
    
    if exist(PPmode) == 0 || modeNiiPara.bytes == 0
        throw(MException('PPS:NIfTICheck',PPmode,'is missing or is empty. Preprocessing cancelled');
        return
    end
    
    run(PPmode)

end

