function [ output_args ] = ppDicomCheck(path,volumes,size)

cd(path);
content=dir('*.IMA');

%%%%CHECK: calc
if length(content) ~= volumes
    calc=volumes-length(content);
    %throw(MException('PPS:DICOMCheck','DICOMs are missing');
    %write file: ('Warning: ', 'calc,' DICOM files missing');
end

% %tarPath=strcat(path,...name);
% if exist(tarPath)
%    tar=dir(tarPath);
%    
%    if tar.bytes < size
%       %throw(MException('PPS:DICOMCheck','.tar is too small');
%      %write file: ('Warning: ', 'calc,' .tar file is too small');
%    end
%    
% else
%      %throw(MException('PPS:DICOMCheck','.tar is missing');
%      %write file: ('Warning: ', 'calc,' .tar file is missing');
% end
