function [ info ] = import_dicom(workingDir,fileName)
%Imports a DICOM to the subject folder and creates the appropriate
%folders and links

workingDir         = get_full_path(workingDir);
DS                 = filesep(); 

%% Read out basic information about the scan
fileName           = lower(fileName);
filePath           = strcat(workingDir,'transfer',DS,fileName);
[info,header]      = fileinfo(filePath);
subject            = lower(header.PatientName.FamilyName);
measurement        = lower(header.PatientName.GivenName);
scanId             = strcat('scan_', sprintf('%04d', header.SeriesNumber));
paradigm           = lower(header.ProtocolName);
scanDate           = datestr(datenum(header.AcquisitionDate, 'yyyymmdd'), 'yyyy-mm-dd');

%% Gather paths to required folders
subjectsDir        = strcat(workingDir,        'subjects',         DS);
subjectDir         = strcat(subjectsDir,       subject,            DS);
measurementDir     = strcat(subjectDir,        measurement,        DS);
scanDir            = strcat(measurementDir,    scanId,             DS);
dicomDir           = strcat(scanDir,           'dicom',            DS);
niftiDir           = strcat(scanDir,           'nifti',            DS);

measurementsDir    = strcat(workingDir,        'measurements',     DS);
measurementDateDir = strcat(measurementsDir,   scanDate,           DS);
measurementLinkDir = strcat(measurementDateDir,subject,            DS);

dirs = {subjectsDir subjectDir measurementDir scanDir dicomDir niftiDir measurementsDir measurementDateDir measurementLinkDir};

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

%% Create symbolic links from measurements dir to the scans if not already existent

measurementLink    = strcat(measurementLinkDir,   scanId);
scanTarget         = strcat('..', DS, '..', DS, '..', DS, 'subjects', DS, subject, DS, measurement, DS, scanId);

if ( ~is_symlink(measurementLink) )
    status = create_symlink(scanTarget, measurementLink);
    
    if ( status == 0 )
        throw(MException('PPS:IOError','Failed in creating link from "%s" to "%s". Error message was "%s".', measurementLink, scanTarget, mess));
    end
end

%% Create symbolic links from the paradigm name to the corresponding scan if not already existent

paradigmLink       = strcat(measurementDir, paradigm);
scanTarget         = scanId;

if ( ~is_symlink(paradigmLink) )
    status = create_symlink(scanTarget, paradigmLink);
    
    if ( status == 0 )
        throw(MException('PPS:IOError','Failed in creating link from "%s" to "%s". Error message was "%s".', paradigmLink, scanTarget, mess));
    end
end

%% Move DICOM to the subject directory
dicomPath               = strcat(dicomDir, fileName);
[status, mess, messid]  = movefile(filePath, dicomPath);

if ( status == 0 )
    throw(MException('PPS:IOError','Failed in moving DICOM "%s" from transfer to subject folder. Error message was "%s".', fileName, mess));
end

end