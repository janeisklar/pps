function [ info, header ] = ppFileinfo( file )

%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
DS      = filesep();
info    = regexpi(file, strcat(DS, '?(?<subject>[A-Z\d-]+)_(?<measurement>[A-Z\d-]+)\.(?<modality>[A-Z\d]+)\.(?<owner>[A-Z\d_]+)\.(?<run>\d+)\.(?<instance>\d+)\.(?<expDate>\d+\.\d+\.\d+)\.(?<expTime>\d+\.\d+\.\d+)\.(?<rest1>\d+)\.(?<rest2>\d+)\.IMA$'), 'names');
header  = dicominfo(file);

end

