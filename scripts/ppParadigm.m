function [ output_args ] = 	ppParadigm(scanDir)
% searches for (specific) paradigm.txt

DS = filesep();
dicomDir=strcat(scanDir,DS,'dicom',DS);
niftiDir=strcat(scanDir,DS,'nifti',DS);

[volumes,files]=ppGetFilesUsingPattern(dicomDir, '\.ima$');

%error in case folder does not contain a DICOM file
if volumes<1
    throw(MException('PPS:DICOMCheck','Failed to read information, DICOMs are missing'));
    return
end


filePath=strcat(dicomDir,files{1});

[info,header]=ppFileinfo(filePath);

measurement= header.PatientName.GivenName;
paradigm= header.ProtocolName;

%error in case DICOM header is empty
if measurement || paradigm == 0
    throw(MException('PPS:DICOMCheck','Failed to read DICOM header, a is missing');
end

%% search paradigms_x

specParadigm=strcat('paradigms_',measurement,'.txt');

%search for the right paradigm.txt
if exist(specParadigm)
    
    paradigmPath=strcat(pwd,DS,specParadigm);
    
elseif exist('paradigms.txt')
    paradigmPath=strcat(pwd,DS,'paradigms.txt');
else
    throw(MException('PPS:DICOMCheck','Failed to read paradigm, paradigms.txt is missing'));
end

[PPmode,dicomVolumes,tarSize]=ppReadParadigm(paradigmPath,paradigm);

ppDicomCheck(dicomDir,dicomVolumes,tarSize)

% error if no preprocessing mode is specified in paradigm.txt
if length(PPmode)<1
    
    throw(MException('PPS:DICOMCheck','Failed to read paradigm, mode is missing in paradigm.txt'));
    
end

if PPmode(1:1)~='-'
    
    ppNiftiCheck(niftiDir,PPmode)
    
end
