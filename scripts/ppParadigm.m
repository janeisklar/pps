function [ output_args ] = 	ppParadigm(scanDir)


DS = filesep();
dicomDir=strcat(scanDir,DS,'dicom',DS);
niftiDir=strcat(scanDir,DS,'nifti',DS);

[volumes,files]=get_files_using_pattern(dicomDir, '\.ima$');

if volumes<1
    throw(MException('PPS:DICOMCheck','Failed to read information, DICOMs are missing'));
    return
end


filePath=strcat(dicomDir,files{1});

[info,header]=fileinfo(filePath);

measurement= header.PatientName.GivenName;
paradigm= header.ProtocolName;

if measurement || paradigm == 0
    throw(MException('PPS:DICOMCheck','Failed to read DICOM header, a is missing');
end

%% search paradigms_x

specParadigm=strcat('paradigms_',measurement,'.txt');

if exist(specParadigm)
    %writeProto: 'specified paradigm for' measurement
    paradigmPath=strcat(pwd,DS,specParadigm);
    
elseif exist('paradigms.txt')
    paradigmPath=strcat(pwd,DS,'paradigms.txt');
else
    throw(MException('PPS:DICOMCheck','Failed to read paradigm, paradigms.txt is missing'));
end

[PPmode,dicomVolumes,tarSize]=ppReadParadigm(paradigmPath,paradigm);

ppDicomCheck(dicomDir,dicomVolumes,tarSize)

if length(PPmode)<1
    
    throw(MException('PPS:DICOMCheck','Failed to read paradigm, mode is missing in paradigm.txt'));
    
end

if PPmode(1:1)~='-'
    
    ppNiftiCheck(niftiDir,PPmode)
    
end
