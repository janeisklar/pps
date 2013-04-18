function [ status ] = ppCheckParadigmDicom(path,nVolumes,size)
% Checks if any DICOM files are missing and verifies the size of
% DICOM archive

status          = 0;
[volumes,files] = ppGetFilesUsingPattern(path, '\.ima$');

%% Error if DICOMs are missing
if volumes <  nVolumes
    throw(MException('PPS:DICOMCheck','DICOMs are missing (was: %d, expected: %d)', volumes, nVolumes));
    return
end

tarPath=strcat(path,'dicom.tar.gz');

%% Error if DICOM archive is missing
if exist(tarPath) < 1
  throw(MException('PPS:DICOMCheck','Dicom.tar.gz is missing!'));
  return
end

tar             = dir(tarPath);

%% Error if DICOM archive is too small
if size>tar.bytes/(1024^2)
  throw(MException('PPS:DICOMCheck','dicom.tar.gz tar-file is too small(was: %.2f MB, expected: >%d MB)', tar.bytes/(1024^2), size));
  return
end

status          = 1;
