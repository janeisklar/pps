function [ ] = ppVerifyScan( scanDir )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

DS          = filesep();

dicomDir    = strcat(scanDir,  'dicom', DS);

niftiDir    = strcat(scanDir,  'nifti', DS);
nifti4dPath = strcat(niftiDir, 'vols.nii');

archiveName = 'dicom.tar.gz';
archivePath = strcat(dicomDir, archiveName);

%% Check if 4D-nifti exists
if ( exist(nifti4dPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','4d-nifti missing: "%s".', nifti4dPath)); 
end

%-----------------------------------------------------------------------------------------------------------
    
%% Check if 4D-nifti is valid
% Get number of DICOMs
[nDicoms, unused] = ppGetFilesUsingPattern(dicomDir, '\.ima$');
    
% Determine the number of volumes in the 4D-nifti
nVolumes = ppGetVolumeCountNifti4d(nifti4dPath);
    
if (nVolumes < nDicoms)
    throw(MException('PPS:VerificationError','4d-nifti contains too few volumes: "%s".', nifti4dPath)); 
end

%-----------------------------------------------------------------------------------------------------------

%% Check DICOM archive exists
if ( exist(archivePath, 'file') == 0 )
    throw(MException('PPS:VerificationError','DICOM-archive missing: "%s".', archivePath)); 
end

%-----------------------------------------------------------------------------------------------------------

%% Check if DICOM archive is valid
% Get number of files in the archive
nFiles      = ppGetTarFileCount(archivePath);

% Compare the number of files in the archive with those in the DICOM folder
if ( nFiles < nDicoms )
    throw(MException('PPS:VerificationError','DICOM-archive contains too few DICOMs: "%s".', archivePath));
end

%-----------------------------------------------------------------------------------------------------------

%% Check if statistical derivates exist
meanPath = strcat(niftiDir, 'mean.nii');
stdPath  = strcat(niftiDir, 'std.nii');
snrPath  = strcat(niftiDir, 'snr.nii');

if ( exist(meanPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','Mean volume is missing: "%s".', meanPath)); 
end

if ( exist(stdPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','Standard deviation volume is missing: "%s".', stdPath)); 
end

if ( exist(snrPath, 'file') == 0 )
    throw(MException('PPS:VerificationError','Signal-to-noise volume is missing: "%s".', snrPath)); 
end

%-----------------------------------------------------------------------------------------------------------

%% Check DICOM exustence and header for paradigm.txt

DS = filesep();
dicomDir=strcat(scanDir,DS,'dicom',DS);
niftiDir=strcat(scanDir,DS,'nifti',DS);

[volumes,files]=ppGetFilesUsingPattern(dicomDir, '\.ima$');

if volumes<1
    throw(MException('PPS:DICOMCheck','Failed to read information, DICOMs are missing'));
    return
end


filePath=strcat(dicomDir,files{1});

[info,header]=ppFileinfo(filePath);

measurement= header.PatientName.GivenName;
paradigm= header.ProtocolName;

if measurement || paradigm == 0
    throw(MException('PPS:DICOMCheck','Failed to read DICOM header, a is missing');
end
%-----------------------------------------------------------------------------------------------------------

%% Check existence and content of paradigm.txt

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

%-----------------------------------------------------------------------------------------------------------

%.txt to String
txt = textread(path, '%s','delimiter', '\n');
foundParadigm=false;

% search for the right paradigm in .txt
for i=1:length(txt)
    
    tmpStr=txt{i};
    parameters=regexpi(tmpStr,'(?<link>[\w]*)\s(?<preproc>[\w|\D]*)\s(?<volumes>[\d]*)\s(?<size>[\d]*)', 'names');
    
    if strcmp(parameters.link,'') || strcmp(parameters.preproc,'')|| strcmp(parameters.volumes,'')|| strcmp(parameters.size,'')
         throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt');
    end
   
    if parameters.link(1:1)==paradigm(1:1)
        foundParadigm=true;
        preproc=parameters.preproc;
        volumes=parameters.volumes;
        size=str2num(parameters.size);
        %ppDicomCheck(parameters.volumes,parameters.size)  
        
    end
    
    
end

if foundParadigm==false
    throw(MException('PPS:DICOMCheck','couldnt find Paradigm in .txt');
end

%-----------------------------------------------------------------------------------------------------------

%% Check DICOM completeness (incl. .tar-file)

[volumes,files]=ppGetFilesUsingPattern(path, '\.ima$');

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

%-----------------------------------------------------------------------------------------------------------

%% Check NIFTI files

nii=strcat(path,'vols.nii');
modeNii=strcat(path,PPmode,'vols.nii');

niiPara=dir(nii);
modeNiiPara=dir(modeNii);


if exist(nii) == 0 || niiPara.bytes == 0
    
    throw(MException('PPS:NIfTICheck','vols.nii is missing or is empty');
    %write file: ('Warning: ',' vols.nii is missing');
end

if exist(modeNii) == 0 || modeNiiPara.bytes == 0
    
    throw(MException('PPS:NIfTICheck',PPmode,'vols.nii is missing or is empty. Preprocessing in progress');
    %write file: ('Warning: ', PPmode,' vols.nii is missing');
    
    if exist(PPmode) == 0 || modeNiiPara.bytes == 0
        throw(MException('PPS:NIfTICheck',PPmode,'is missing or is empty. Preprocessing cancelled');
        return
    end
    
    run(PPmode)

end

end

