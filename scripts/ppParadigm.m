function [ output_args ] = 	ppParadigm(scanDir)

dicomDir=strcat(scanDir,'\dicom');
niftiDir=strcat(scanDir,'\nifti');

%%%%CHECK%%%%
%[volumes,files]=get_files_using_pattern(dicomDir, '\.ima$');
volumes=1;
if volumes<1
    % throw(MException('PPS:DICOMCheck','Failed to read information, DICOMs are missing');
    %% exit? return?
end

%filePath=strcat(newDir,files(1));

%%%%%%%%REPLACE%%%%%%%%%%%%%
filePath='E:\Uni\CognitiveScience\fMRI\pps12\subjects\ssh11_fc01\m1\dicom\CLU12-P020_7T.MR.PHYSIKER_RSLADKY.0005.0001.2012.03.28.12.32.30.734375.14886227.IMA';

[info,header]=fileinfo(filePath);

measurement= header.PatientName.GivenName;
paradigm= header.ProtocolName;

%%%%CHECK%%%%
% if measurement || paradigm == 0
%     %throw(MException('PPS:DICOMCheck','Failed to read DICOM header, a is missing');
% end

%% search paradigms_x

specParadigm=strcat('paradigms_',measurement,'.txt');

if exist(specParadigm)
    %writeProto: 'specified paradigm for' measurement
    paradigmPath=strcat(pwd,'\',specParadigm);
    
elseif exist('paradigms.txt')
    paradigmPath=strcat(pwd,'\paradigms.txt');
else
    %throw(MException('PPS:DICOMCheck','Failed to read paradigm, paradigms.txt is missing');
end

[PPmode,dicomVolumes,tarSize]=ppReadParadigm(paradigmPath,paradigm);

ppDicomCheck(dicomDir,dicomVolumes,tarSize)  
ppNiftiCheck(niftiDir,PPmode)
