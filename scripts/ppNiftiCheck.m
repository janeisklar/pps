function [ output_args ] = ppNiftiCheck(path,PPmode)

nii='vols.nii';
modeNii=strcat(PPmode,'vols.nii');

cd(path);

niiPara=dir(nii);
modeNiiPara=dir(modeNii);


if exist(nii) == 0 || niiPara.bytes == 0
    
    %throw(MException('PPS:NIfTICheck','vols.nii is missing or is empty');
    %write file: ('Warning: ',' vols.nii is missing');
end

if exist(modeNii) == 0 || modeNiiPara.bytes == 0
    
    %throw(MException('PPS:NIfTICheck',PPmode,'vols.nii is missing or is empty');
    %write file: ('Warning: ', PPmode,' vols.nii is missing');
end