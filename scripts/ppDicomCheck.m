function [ output_args ] = ppDicomCheck(path,txtVolumes,size)

[volumes,files]=get_files_using_pattern(path, '\.ima$');

if volumes < txtVolumes
    
    calc=txtVolumes-volumes;
    throw(MException('PPS:DICOMCheck','DICOMs are missing'));
    %write file: ('Warning: ', 'calc,' DICOM files missing');
    
end

tarPath=strcat(path,'dicom.tar.gz');

if exist(tarPath)
    tar=dir(tarPath);
    
    if size>tar.bytes/(1024^2)
        
        throw(MException('PPS:DICOMCheck','tar-file is too small'));
        %write file: ('Warning: ', 'calc,' tar file is too small');
        
    end
    
else
    throw(MException('PPS:DICOMCheck','.tar is missing'));
    %write file: ('Warning: ', 'calc,' .tar file is missing');
end
