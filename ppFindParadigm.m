function [ paradigm, paradigmPath ] = ppFindParadigm(workingDir, scanDir)
% Finds the corresponding paradigm for a scan directory

DS                = filesep();
dicomDir          = strcat(scanDir,DS,'dicom',DS);

[volumes,files]   = ppGetFilesUsingPattern(dicomDir, '\.ima$');

%% Error in case folder does not contain a DICOM file
if ( volumes < 1 )
    throw(MException('PPS:DICOMCheck','Failed to read information, DICOMs are missing'));
    return
end

%% Find the first dicom there is and extract the header information to get to the paradigm
filePath          = strcat(dicomDir,files{1});
[info,header]     = ppFileinfo(filePath);

measurement       = header.PatientName.GivenName;
paradigm          = header.SeriesDescription;

%% Error in case DICOM header is empty
if ( isempty(measurement) || isempty(paradigm) )
    throw(MException('PPS:DICOMCheck','Failed to read DICOM header, data is missing'));
end

%% Search for the right paradigm(_xxx).txt
specParadigm      = strcat('paradigms_', measurement, '.txt');
specParadigmPath  = strcat(workingDir, 'jobs', DS, specParadigm);
paradigmPath      = strcat(workingDir, 'jobs', DS, 'paradigms.txt');

if ( exist(specParadigmPath) > 0 )
    paradigmPath  = specParadigmPath;
end

if ( exist(paradigmPath) < 1 )
    throw(MException('PPS:DICOMCheck',['Failed to read paradigm, ' paradigmPath ' and '  specParadigmPath ' are missing']));
    return
end

end