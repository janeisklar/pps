function [ info ] = import_dicom(workingDir,fileName)
%Imports a DICOM to the subject folder and creates the appropriate
%folders and links

workingDir      = get_full_path(workingDir);
DS              = filesep(); 

%% Read out basic information about the scan
filePath        = strcat(workingDir,'transfer',DS,fileName);
[info,header]   = fileinfo(filePath);
scanId          = strcat('scan_', info.run);

%% Gather paths to required folders
subjectsDir     = lower(strcat(workingDir,        'subjects',         DS));
subjectDir      = lower(strcat(subjectsDir,       info.subject,       DS));
measurementDir  = lower(strcat(subjectDir,        info.measurement,   DS));
scanDir         = lower(strcat(measurementDir,    scanId,             DS));
dicomDir        = lower(strcat(scanDir,           'dicom',            DS));
niftiDir        = lower(strcat(scanDir,           'nifti',            DS));

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

%% Create symbolic links to measurements and scans if not already existent
scanLink        = lower(strcat(subjectsDir,       scanId));
measurementLink = lower(strcat(measurementDir,    info.measurement));

%if ( ~ is_symlink(scanLink) )
%    status = create_symlink(strcat(info.subject, DS, info.measurement));
%end

%% Move DICOM to the subject directory
dicomPath               = lower(strcat(dicomDir, fileName));
[status, mess, messid]  = movefile(filePath, dicomPath);

if ( status == 0 )
    throw(MException('PPS:IOError','Failed in moving DICOM "%s" from transfer to subject folder. Error message was "%s".', fileName, mess));
end

end