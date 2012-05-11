function [ info, header ] = fileinfo( file )

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

info=regexpi(file,'\/?(?<subject>[A-Z\d-]+)_(?<measurement>[A-Z\d-]+)\.(?<modality>[A-Z\d]+)\.(?<owner>[A-Z\d_]+)\.(?<run>\d+)\.(?<instance>\d+)\.(?<expDate>\d+\.\d+\.\d+)\.(?<expTime>\d+\.\d+\.\d+)\.(?<rest1>\d+)\.(?<rest2>\d+)\.IMA$', 'names');
header=dicominfo(file);

end

