function [ info ] = import_dicom(workingDir,fileName)
%Imports a DICOM to the subject folder and creates the appropriate
%folders and links

%% Read out basic information about the scan
filePath=strcat(workingDir,'transfer','/',fileName);
[info,header] = fileinfo(filePath);

%% Gather paths to required folders
subjectsDir     = lower(strcat(workingDir,        'subjects/'));
subjectDir      = lower(strcat(subjectsDir,       info.subject,       '/'));
measurementDir  = lower(strcat(subjectDir,        info.measurement,   '/'));
scanDir         = lower(strcat(measurementDir,    'scan_',            info.run,   '/'));
dicomDir        = lower(strcat(scanDir,           'dicom/'));
niftiDir        = lower(strcat(scanDir,           'nifti/'));

dirs = {subjectsDir subjectDir measurementDir scanDir dicomDir niftiDir};

%% Check if folders already exist or create them otherwise
for dir=dirs

    if ( exist(dir{1}, 'dir') > 0 )
        continue;
    end
    
    [status, mess, messid] = mkdir(dir{1});
    
    if ( status > 0 )
        continue;
    end
    
    throw(MException('PPS:IOError','Failed in creating directory "%s". Error message was "%s".', dir{1}, mess));
end

%% Move DICOM to the subject directory
dicomPath               = lower(strcat(dicomDir, fileName));
[status, mess, messid]  = movefile(filePath, dicomPath);

if ( status == 0 )
    throw(MException('PPS:IOError','Failed in moving DICOM "%s" from transfer to subject folder. Error message was "%s".', fileName, mess));
end

end