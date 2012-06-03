function [ output_args ] = ppDicomCheck(amount)


%%%DIR%%%
content=dir('*.IMA');
if length(content) ~= amount
    calc=amount-length(content);
    %write file: ('Warning: ', 'calc,' DICOM files missing');
end