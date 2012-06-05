function [ output_args ] = ppDicomCheck(path,volumes,size)

cd(path);
content=dir('*.IMA');

if length(content) ~= volumes
    calc=volumes-length(content)
    %write file: ('Warning: ', 'calc,' DICOM files missing');
end

