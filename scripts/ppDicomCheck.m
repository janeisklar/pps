function [ output_args ] = ppDicomCheck(path,txtVolumes,size)
% Checks if any DICOM files are missing and verifies the size of
% DICOM archive

[volumes,files]=get_files_using_pattern(path, '\.ima$');

%error if DICOMs are missing
if volumes < txtVolumes
    
    calc=txtVolumes-volumes;
    throw(MException('PPS:DICOMCheck','DICOMs are missing'));
   
    
end

tarPath=strcat(path,'dicom.tar.gz');

%error if DICOM archive is to small or missing
if exist(tarPath)
    tar=dir(tarPath);
    
    if size>tar.bytes/(1024^2)
        
        throw(MException('PPS:DICOMCheck','tar-file is too small'));
        
        
    end
    
else
    throw(MException('PPS:DICOMCheck','.tar is missing'));
    
end
